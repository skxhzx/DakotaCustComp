      /COPY *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *  Special Reminder:  This program was changed with mods 730a
     *  thru 730c which enables the defintion of soft coded pick
     *  sequencing.  Before trying to modify the hardcoded portion
     *  of this program please review file DFPICKDTL and DFPICKPSQ
     *  to determine if soft coding is used.  If these files exist
     *  and either have records, this program will use the softcoded
     *  routine softcode, otherwise it will run routine originalMain
     *  which represents the original hardcoded sequencing.  When
     *  soft coding is used please use MRC program M293xx
     *  to maintain DFPICKDTL and M292xx to maintain the pseq sort
     *  if not using slot file pseq. These options can be found on MRC
     *  menu Maintenance/Pick Order Seq.
     *----------------------------------------------------------------
     *
     *  DFPICK    Program to redefine pick sequence using LBLVL2.
     *            This program is called from OR605.
     *  12 April 2004
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    04/12/04  DAS  4.17
     *      - Created
     *
417aA*    08/05/04  DAS  4.17a
     *      - Changed beginning of DF from 101 to 098.
     *
500 A*    08/31/05  DAS  5.00
     *      - Revised program to be used by all clients.
     *      - Revised program to add support for Client id
     *
500aA*    08/31/05  DAS  5.00a
     *      - Added logic for BiRite.
     *      - Created subroutines for each client.
     *      - Moved Cheney code into cheneyseq subroutine.
     *      - Deleted original code from main line for readability.
     *
500bA*    01/10/06  DAS  5.00b
     *      - Added file WORKLBL (needed for Cheney).
     *      - Revised Cheney logic to handle PRD zone independently.
     *
500cA*    03/02/06  DAS  5.00c
     *      - Added logic for I-Supply.
     *
500dA*    03/06/06  DAS  5.00d
     *      - Added FRZ logic for I-Supply.
     *
500eA*    04/13/06  DAS  5.00e
     *      - Added logic for Harbor.
     *
500fA*    05/04/06  DAS  5.00f
     *      - Added logic for EI.
     *
500gA*    01/17/06  DAS  5.00g
     *      - Revised Cheney logic to handle PRDPIR zone independently.
     *
500hA*    01/23/06  DAS  5.00h
     *      - Implemented a special pick path for Ocala's CLR department.
     *
500iA*    02/23/06  DAS  5.00i
     *      - Tweaked special pick path for Ocala's CLR department.
     *
510 A*    12/20/06  MLB  5.10
     *      - Revised routine CHENEYSEQ to change starting location
     *        for sequence 5 DF aisle to 219 from 221.
     *
510aA*    06/14/06  DAS  5.10a
     *      - For I-Supply changed dept FRZ to FROZ.
     *      - Removed item 080025, 080099 & 080101.
     *        - Was originally done by RH on 5/22/06 5.00e.
510bA*    08/10/06  RH   5.10b
     *      - Added logic for Andrews.
510cA*    12/14/06  DAS  5.10c
     *      - Added logic for GSC.
510dA*    06/01/07  DAS  5.10d
     *      - Added logic for ELB.
510eA*    06/12/07  DAS  5.10e
     *      - Revised ISupply to also work with Merge records.
510fA*    11/06/07  DAS  5.10f
     *      - Added logic for TPC.
510gA*    10/10/07  HNK  5.10g
     *      - Added logic for BiRite.
510hA*    01/10/08  RBD  5.10h
     *      - Reverse rev 500e, bypass logic for Harbor.
510iA*    01/10/08  RBD  5.10i
     *      - Enh: Added new *IEMMNT/OPHVY option, for determining
     *        weight of 'heavy' items ... for EBL.
     *        This rev was implemented at EBL 06/11/07 as rev 510e,
     *        and because of my oversight, is just now being added
     *        to our 5.10 version. Chg'd to 510i as 510e was used.
520aA*    03/11/08  DAS  5.20a
     *      - Added logic for CDI.
520bA*    04/05/08  DAS  5.20b
     *      - Gutted Harbor logic. Re: Their previous version of
     *        OR605 said it called DFPICK but it didn't. The new
     *        version of OR605 does call DFPICK, so we need to change
     *        DFPICK so it doesn't do anything for Harbor.
520cA*    08/20/08  DAS  5.20c
     *      - Added logic for City Wholesale.
520dA*    04/30/09  RH   5.20d
     *      - Added logic for Jack Palmer.
520eA*    09/15/09  HNK  5.20e
     *      - Added logic for Royal.
520eA*    07/27/09  RH   5.20e
     *      - Added logic for Saval.
520fA*    10/16/09  MLB  5.20f
     *      - Added aisles 70 to 77 after aisle 62 in DRY.
     *      - This is for the holiday season only.
     *        Done for EI. Per Don Duncan voice message.
520gA*    10/30/08  RH   5.20g
     *      - Added logic for Jordanos
     *
530 A*    10/27/10  JCJ  5.30
     *      - Revised routine CHENEYSEQ to change ending location
     *        for sequence 6 DK aisle to 243 from 256.
     *      - Revised Cheney logic to handle FLRPIR zone independently.
     *      - Revised routine CHENEYSEQ to add locations for sequence
     *        8 DK aisle from 246 through 261.
     *      - Revised routine CHENEYSEQ to change sequence 7 DL
     *        aisle to 9.
     *      - Revised routine CHENEYSEQ to change sequence 8 DM
     *        aisle to 10.
     *      - Revised routine CHENEYSEQ to change sequence 9 DN
     *        aisle to 11.
     *      - Revised routine CHENEYSEQ to change sequence 10 DF
     *        aisle to 12.
     *
530a *    01/20/10  GJA  5.30a
     *      - Added logic for Halsey.
     *
530bA*    06/15/10  MLB  5.30b Ellenbee-Leggett
     *      - Enh: Revised program to sequence aisle 2Z after slot
     *        2H1561 and before aisle 2J.
530c *    07/06/10  GJA  5.30c
     *      - Added logic for Fischer
     *
640 A*    09/30/12  JCJ  OCAa
     *      - added Ailes CE - CJ per Gus Castrillon.
640a *    02/17/11  DAS  6.40a
     *      - Added logic for Dierks Waukesha
640b *    07/12/12  GJA  640b
     *      - Added logic for Intercounty Bakers
640cA*    12/09/11  DAS  6.40c orig 5.20b on 3-18-08 missed update
     *      - Added DRI logic
     *      - Revised CDI logic to make CHEM items first.
     *
650 A*    05/16/14  MLB  6.50  P#01218
     *      - Revised program to add new CHYGWBSEQ routine.
650aA*    09/16/14  MLB  6.50a  P#01218
     *      - Revised mod 6.50 to remove location ranges from
     *        aisle sequence selections.
     *
650b *    11/06/12  GJA  650b
     *      - Added logic for Eastland
     *
700a *    08/24/15  GJA  700a
     *      - Added logic for CityLine
700bA*    07/12/16  TAB  700b
     *      - Added logic to use WORKLBL logical when parm
     *        'PREPLTBLD' is passed instead of LABEL13
     *        (SETLL/READE/UPDATE)
730aA*    05/08/19  KDE  730a
     *      - Added logic to handle soft coded LVL2
730bA*    06/07/19  KDE  730b
     *      - Added logic to handle additional soft coded variables
     *      - Add ability to call from testing program (M29500)
     *        This process passes a label and it will either return
     *        a space delimited list of ID's or *NONE if nothing found
730cA*    07/16/19  KDE  730c
     *      - Add monitor in case GETPSEQO not found
     *
730dA*    10/15/19  DAS  7.30d
     *      - Revised to use LABELW, WORKLBLW
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
     *
JORaA*    10/30/08  RH   JORa
     *      - Added code for aisles H, I, J, K, L, M new and old.
JORbA*    01/28/09  RH   JORb
     *      - Disable JORSEQ, old I, J, K, L and M aisles deleted,
     *        special sequencing no longer needed.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    05/23/06  MLB  EI
     *      - Added aisles 61, 62 after aisle 18 in DRY for EI.
EIa A*    04/11/08  MLB  EIa
     *      - Added aisles 46, 47, 48 before aisles 41-45 in REF.
EIb A*    10/26/12  MLB  EIb
     *      - Revised pgm to sequence aisles 80-82 after aisle 77
     *        in dept DRY. Per email from Don D. dated 10-25-12 10:26am.
EIc A*    03/24/14  RH   EIc
     *      - Revised pgm to sequence dept FRZ, CANDY, DRY, REF for
     *        new whse per Don.                                       m.
EId A*    12/17/14  MLB  EId
     *      - Revised pgm to sequence dept DRY aisles in sequence:
     *        11,7,8,9,10,12,13,14,15,16,17,18 and 19. Per Don D. email
     *        dated 12/12/14.
EIe A*    03/06/15  MLB  EIe
     *      - Revised pgm to sequence dept CANDY at seq 5.
     *        Sequence dept REF at seq 35.
     *        Sequence dept FRZ at seq 40.
     *        Per Greg F. request to Roxanne.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HALa *    01/20/10  GJA  HALa
     *      - Added dept REF to pick aisle PA thru PE at the end.
     *
HALb *    02/14/10  GJA  HALb
     *      - Added aisle RE to be picked after CA. Changed aisle PA-
     *        PE to be level 51, CA-CK to be level 1, RE309-RE315 to
     *        be level 2, and the rest to be level 50.
HALc *    04/10/10  RH   HALc
     *      - Added aisle FI to be picked first in FRZ.
HALd *    11/06/11  GJA  HALd
     *      - Added aisle DK-000 thru DK-0004 picked first for aisle DK
HALe *    04/04/13  RBD  HALe
     *      - Per S Neeley, change pick sequence for FRZ to pick aisles
     *        FI, FJ, FK, FL, FM, and then FA last.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
     *
FSHa *    01/12/12  GJA  FSH
     *      - Added slots to pick at end of DRY & REF
     *
FSHb *    06/20/12  GJA  FSHb
     *      - Change item selection
     *
FSHc *    04/30/13  GJA  FSHc
     *      - Added additional items
     *
FSHd *    05/22/14  GJA  FSHd
     *      - Added additional items
FFCeA*    12/14/15  MLB  FFCe
     *      - Revised pgm to pick slot 40-101-1 after slot 44-104-2.
     *        Per Mike T. email dated 12.12.2015.
FFCfA*    08/09/17  MLB  FFCf
     *      - Revised pgm to aisle 76 in FRZ then aisles 70 - 73.
     *        Per Hemant email dated 08.08.2017.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTW A*    06/16/08  ???  CTW
     *      - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash-Wa
     *
CWDa *    07/07/09  HNK  CWDa
     *      - Pick aisle 42, 41 and then 40 in cooler dept for Aberdeen
CWDbA*    09/25/14  MLB  CWDb
     *      - Revised CWDa mod. Changed dept code to CLR from dept P.
     *        As part of upgrade to full system Dakota.
CWDcA*    03/10/16  MLB  CWDc
     *      - Removed CWDa, CWDb mods. No custom sorts in place at this
     *        time. All aisles default to seq. 50.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    09/16/15  GJA  JSLa
     *      - Pick aisle 32, then 31 after 30
     *
JSLb *    10/25/15  GJA  JSLb
     *      - When Dry & Cooler are combined, move aisle 20 to first
     *        pick
JSLc *    11/11/15  GJA  JSLc
     *      - Pick 20, DRY, 73, 72, 71, 70, 30, 32, 31. 74
JSLd *    01/25/17  GJA  JSLd
     *      - Pick Freezer like:
     *      11-221 backwards to 11-200
     *      12-348 backwards to 12-300
     *      11-254 backwards to 11-225
     *      10-118 backwards to 10-100
     *      13-400 forwards to 13-428
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
EFCa *    11/06/12  GJA  EFCa
     *      - Added RICE aisle to be picked first
     *
EFCb *    12/09/13  GJA  EFCb
     *      - Added weight condition
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPCaA*    02/26/08  RH   TPCa
     *      - Added REF between DRY aisle 04 and 07.
TPCbA*    03/03/08  MLB  TPCb
     *      - Added DRY / 01 at end of all DRy zone stuff.
TPCcA*    04/06/12  RBD  TPCc
     *      - Added aisle 79, aisle/loc 71-218 through 71-233, and
     *        aisle 80 to print near the end, in this order, just
     *        before DRY aisle 01.
TPCdA*    12/12/13  RBD  TPCd
     *      - Changed locs in aisle 71 from 218-233 to 214-241.
TPCeA*    02/04/15  RBD  TPCe
     *      - Changed locs in aisle 71 from 214-241 to 210-241.
TPCfA*    02/17/15  RBD  TPCf
     *      - Commented out all TPC logic and replaced with new
     *        sequencing per Steve Williams.
TPCgA*    09/11/17  RBD  TPCg
     *      - Per Steve Williams changed sequencing as follows:
     *        Replace DRY 70 or DRY 71<210 or DRY 71>241 or
     *          DRY 72-76 with DRY 70-79
     *        Remove DRY 81
     *        Remove DRY 71 210-241
     *        Remove DRY 80
TPChA*    06/11/18  MLB  TPCh
     *      - Per Steve Williams changed sequencing as follows:
     *        Seq dept REF/F aisles 20-22
     *            dept REF/F&P aisle 23
     *            dept REF/F aisles 24-26
     *            dept REF/F&P aisle 27
     *            dept REF/F aisles 28-31
     *            dept REF/F&P aisle 32
     *            dept REF/F aisles 33-34
     *            dept REF/F&P aisle 35
     *            dept REF/F aisles 36-39
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    07/27/09  RH   SVLa
     *      - Added dept(3) REF between(2)DRY aisle B and D
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    06/02/10  MLB  FRF
     *      - Changed pgm to sequence all DRY dept aisles before all
     *        CLR dept aisles.
FRFaA*    11/12/13  MLB  FRFa  P#01143
     *      - Revised pgm to change sort sequence for aisles in all
     *        3 departments, CLR, DRY and FRZ. Per Nick N. email.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland - Hanover
     *
DRY A*    07/14/11  MLB  DRY    Per Email from Hemant - 7/14/11.
     *      - Changed pgm to sequence DRY, REF aisles together as
     *        follows: Dry-A, Ref-R, Dry-T, Ref-W and Dry-Y.
DRYaA*    11/08/11  MLB  DRYa   Per phone call from Kelly R. 11/08/11.
     *      - Temporarily disabled all custom sequencing from
     *        mod DRY above.
DRYbA*    11/10/11  MLB  DRYb   Per email from Kelly R. 11/09/11.
     *      - Changed sort sequence for aisles as listed below.
     *        DRY - seq 10 = A1 - A7 (020 - 027)
     *        REF - seq 15 = 060 - 064
     *        CHC/REF - seq 20 = 080 - 085
     *        REF - seq 25 = 100 - 101
     *        DRY - seq 30 = 110
DRYcA*    11/11/11  RH   DRYc
     *      - Fix: Change DairylandSeq to use LBaisl not SLaisl,
     *        did not have slot record in subroutine.
DRYd *    12/05/11  GJA  DRYd
     *      - Fix: Correct slot sequencing
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland - LA
     *
DRYe *    01/09/12  GJA  DRYe   Per email from Hemant 01/09/12.
     *      - Changed sort sequence for aisles as listed below.
     *        DRY & REF = A1 - A8
     *                    B1 - B4
     *                    W9
     *                    C1 - C2
     *                    M1
     *                    D1
     *                    N1 - N2
     *                    R1 - R5
     *                    J1
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland - Cincinnati
     *
DRYf *    04/07/13  GJA  DRYf
     *      - Changed pgm to sequence DRY, REF aisles together.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland - Bronx
     *
DRYgA*    03/25/15  MLB  DRYg
     *      - Enh: Added pick slot sequencing for Bronx whse per
     *        Kelly R. worksheet. Email dated 03/23/15.
DRYhA*    04/23/15  MLB  DRYh
     *      - Enh: Revised pick slot sequencing per new worksheet from
     *        Kelly R. Email dated 04/23/15.
DRYiA*    04/25/15  MLB  DRYi
     *      - Enh: Revised pick slot sequencing to make REF/016 be first
     *        slot picked. Then begin with aisle 01A.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland - San Francisco
     *
DRYjA*    06/01/16  MLB  DRYj
     *      - Enh: Revised pick sequence for whse 95 SF to sort
     *        dept DRY aisles ahead of dept REF aisles.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland - Chicago
     *
DRYkA*    02/02/17  MLB  DRYk
     *      - Enh: Revised pick sequence for whse 70 Chicago to sort
     *        in custom sequence per Kelly R. email.
     *      - Chicago is picking several departments combined together
     *        which necessitated this mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
     *
HMWaA*    07/17/13  RTR  HMWa   Per Email from Joe H. - 7/15/13.
     *      - Changed pgm to sequence DRY, REF aisles together as
     *        follows: Dry-A, Ref-R, Dry-T, Ref-W and Dry-Y.
HMWbA*    03/05/14  RTR  HMWb   Per Email from Joe H. - 3/05/14.
     *      - Changed pgm to sequence anything in slot CF-113-1
     *        after everything else.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland - Qzina Toronto
     *
DRYmA*    09/13/18  MLB  DRYm
     *      - Enh: Revised pick sequence for whse 30 Toronto to sort
     *        in custom sequence per Kelly R. email.
     *      - Toronto is picking all departments combined together on
     *        will-call orders which necessitated this mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: ISupply
     *
ISPa *    02/21/18  GJA  ISPa
     *      - Changed pgm to sequence DRY, G aisle first.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
     *
KFS A*    10/05/12  MLB  KFS    Per phone call from Hemant - 10/04/12.
     *      - Changed pgm to sequence REF aisles in descending sequence
     *        as follows: Ref-CH, Ref-CF, Ref-CE, Ref-CD, Ref-CC, Ref-CA.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICBa *    07/13/12  GJA  ICBa
     *      - Changed pgm to sequence REF aisles in descending sequence
     *        as follows: Ref-CH, Ref-CF, Ref-CE, Ref-CD, Ref-CC, Ref-CA.
ICBb *    05/15/14  RH   ICBb
     *      - Changed to pick aisles 8 to 30, then aisle 40, last     e
     *        aisle 31.  Change because of move to new warhouse.      CA.
ICBc *    07/29/14  GJA  ICBc
     *      - Changed to pick 40-102-1 first                          e
ICBe *    08/23/19  KDE  ICBe
     *      - Changed to pick 40, 30 and finish 31 in Dry             e
     *
     *----------------------------------------------------------------
CDI A*  Client Custom Revisions: Customized Distributors
     *
     *    01/04/13  RBD  CDI
     *      - Per August and Rod, removed special sequencing for
     *        FRZ aisles 7 through 4.
CDIbA*    05/20/13  RH   CDIb
     *      - Per August, ATL change CLR to pick decending for aisles
     *         8 through 10.
CDIc *    11/15/13  GJA  CDIc
     *      - Added aisle 19 in DRY for correct sequencing
CDId *    08/02/14  GJA  CDId
     *      - Resequence aisle 10 before aisle 9
CDIeA*    12/22/14  MLB  CDIe
     *      - Change pick sequence for whse 3 - Jackson, MS per August
     *        W. 12/21/14 email. Pick DRY aisles 1-2,5 - 11, then 4, 3.
CDIfA*    09/17/15  MLB  CDIf
     *      - Change pick sequence for whse 3 - Jackson, MS per August
     *        W. 09/16/15 email. Pick DRY aisles 5-11, then 4,3,2,50,51
     *        and 1.
CDIgA*    08/12/14  MLB  CDIg
     *      - Fix: Revised 6.40c mod to change sequence for CHEM
     *        designated items to sequence 1 from sequence 2.
CDIhA*    09/03/15  MLB  CDIh
     *      - Fix: Revised CDIg mod. Revised pgm to include aisle 19
     *        locations 593 through 597 at sequence 1. per Roderick F.
     *        email dated 08.31.2015.
CDIiA*    09/03/15  MLB  CDIi
     *      - Fix: Revised CDIg mod. Revised pgm to include aisle 23
     *        after aisle 25, then aisle 18 in dept Dry. Per Rod F.
     *        email dated 08.31.2015.
     *      - Fix: Revised pgm to change sort sequence for dept CLR
     *        beginning at aisle 08, 09 and 10. Per Rod F. email
     *        dated 08.31.2015.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
SGCaA*    01/21/16  RH/MLB  SGCa
     *      - Enh: Change pick seq for DRY XDK to pick after DRY aisle
     *        ' DJ'
SGCbA*    02/11/17  MLB  SGCb
     *      - Enh: Disabled above mod. No longer needed after move to
     *        new DRY whse.
SGCcA*    02/11/17  MLB  SGCc
     *      - Enh: Changed pgm to sequence slots in DC-200-1 thru
     *        DC-255-2 first, then all remaining slots in DRY.
SGCdA*    02/13/17  MLB  SGCd
     *      - Enh: Change pick seq for DRY XDK to pick after DRY aisle
     *        ' DQ'
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S Bertram
     *
SBR A*    02/17/15  MLB  SBR
     *      - Per Hemant, Chaim emails. Chg pgm to provide descending
     *        sequence for dept DRY slots, aisles 10 - 19.
SBRaA*    02/17/15  MLB  SBRa
     *      - Per Hemant, Chaim emails. Chg pgm to provide descending
     *        sequence for dept FRZ slots.
SBRbA*    05/28/15  MLB  SBRb
     *      - Per Chaim F. email. dated 05/26/2015.  Changes to dept
     *        DRY slots. Changes to original mod, SBR.
SBRcA*    06/23/15  MLB  SBRc
     *      - Per Chaim F. email. dated 06/16/2015.  Changes to dept
     *        FRZ slots. Changes to original mod, SBRa.
SBRdA*    10/26/15  RTR  SBRd
     *      - Per Abraham email. dated 10/26/2015, directed by Max.
     *        Comment out DRY changes.
SBRe *    01/30/18  GJA  SBRe
     *      - Per Yosef. Pick cereal last, 14-600 thru 14-633  Max.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI A*    11/18/15  MLB  CBI
     *      - Per Mark E. email dated 11.18.2015, revised pgm to add
     *        custom sequencing for dept DRY, aisles DX and DY for
     *        Punta Gorda.
CBIaA*    12/29/15  MLB  CBIa
     *      - Per Mark E. email dated 12.10.2015, revised pgm to add
     *        custom sequencing for dept FRZ, aisles FX and FY for
     *        Punta Gorda.
CBIbA*    12/30/15  MLB  CBIb
     *      - Per Mark E. email dated 12.10.2015, revised pgm to bypass
     *        slots in FX, FY with designation code, 0IC for PG.
CBIcA*    12/31/15  MLB  CBIc
     *      - Per Mark E. email dated 12.10.2015, revised pgm to
     *        retrieve pick zone for dept FRZ slots. Designation 0IC
     *        is not assigned to any slots in aisles FX, FY. Slots
     *        0IC zone need no sequencing. Change to CBIb mod.
CBIdA*    01/30/16  MLB  CBId
     *      - Per Mark E. email dated 01.27.2016, revised pgm to
     *        remove CBI mod for dept DRY PIR slot. w/o# 2015269.
CBIeA*    03/21/17  MLB  CBIe
     *      - Added routines for Pate Dawson 3 whses.
CBIfA*    03/26/17  MLB  CBIf
     *      - Revised Goldsboro CLR sequences.
CBIgA*    08/19/17  MLB  CBIg     WO# 2017148
     *      - Revised Goldsboro DRY sequences to pick aisle DA first.
CBIhA*    01/28/19  MLB  CBIh     WO# 2019002
     *      - Revised Statesville PRD pick sequences.
CBIiA*    01/28/19  MLB  CBIi (was CBIe at PG)
     *      - Per Mark E. email dated 01.14.2018, revised pgm to
     *        seq dept DRY aisles CL,CM and CN after aisle DP.
     *        Per wo# 2018007.
CBIjA*    01/29/20  MLB  CBIj     WO# 2020010
     *      - Revised whse MLK DRY pick sequences.
CBIkA*    01/29/20  MLB  CBIk     WO# 111953
     *      - Revised whse MLK DRY pick sequences.
     *        Dry Zone pick path: MB ' MC ' MD ' MA
     *      - This mod supersedes CBIj.
CBIlA*    01/06/20  MLB  CBIfl   W/O# 2020001
     *      - Revised pgm to update pick seqs for Greensboro after move
     *        to new whse.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WIL A*    08/31/15  MLB  WIL
     *      - Per Hemant. Change pgm to provide alternate sequencing
     *        aisles in dept D and R.
WILaA*    09/01/15  MLB  WILa
     *      - Per Hemant. Change pgm to provide alternate sequencing
     *        aisles in dept F.
WILbA*    09/01/15  MLB  WILb
     *      - Per Hemant. Change pgm to provide alternate sequencing
     *        aisles 71 and 72 in depts D and R.
WILcA*    09/03/15  MLB  WILc
     *      - Per Hemant. Change pgm to provide alternate sequencing
     *        aisles 51, slots less than 223 or greater than 243.
WILdA*    11/23/15  MLB  WILd
     *      - Per Hemant. Change pgm to sequence aisle 80 after aisle
     *        61 then to 81.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*    02/10/14  MLB  GLP
     *      - Per Hemant's email dated 02/10/14, changed pgm to sequence
     *        aisles per document for Main and Toland warehouses.
GLPaA*    03/10/16  MLB  GLPa
     *      - Deleted all GLP mods from greenleafseq. Those mods were for
     *        their old warehouse. Replaced with sequence changes from
     *        Hemant's email dated 03.10.16.
GLPbA*    03/21/16  MLB  GLPb
     *      - Revised pgm to sequence aisle 12 between aisle 11 and 20.
     *        Per Hemant email dated 03.17.16
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos Foods
     *
PAN A*    02/29/16  MLB  PAN
     *      - Per Hemant. Change pgm to provide alternate sequencing
     *        dept F, R and then D.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    03/22/16  MLB  FPR
     *      - Per Hemant. Change pgm to sort dept DRY ahead of dept CLR
     *        for zone template that combines dept CLR, DRY together.
FPRbA*    06/28/16  RH   FPRb
     *      - Enh: Change to process CLR CF first, then DRY DP - DV,  R
     *        then Clr JA-JK, then DRY JU, JW, KX, KY, KZ.            R
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi Foodservice
     *
RNZ A*    05/31/16  MLB  RNZ  P#01565
     *      - Revised 6.40a mod for Renzi to change aisle pick sequence
     *        to pick CLR/DRY together.
     *      - Note: These changes never made it back to Dev2 so all
     *        previous changes have been left out.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADF A*    10/24/16  MLB  ADF  P#
     *      - Revised program to sequence pick labels in F, R, D se.
     *        Per Hemant K. email dated 10/24/16 4:22 pm CT.
ADFaA*    08/24/17  MLB  ADFa  P#01799
     *      - Revised program to chg pick sequence in Freezer 1 per
     *        Rod Frierson email dated 08/14/17 1:18 pm CT.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGL A*    09/27/17  MLB  FGL
     *      - Per Hemant. Revised pgm to pick dept FRZ aisles in seq:
     *        35,36,38-42 and 09.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco & Sons
     *
GRC A*    10/18/18  MLB  GRC
     *      - Per Hemant. Revised pgm to pick whse per slot map.
GRCaA*    11/03/18  MLB  GRCa
     *      - Per Leo C. Per email dated 11/03/2018.
GRCbA*    04/24/19  MLB  GRCb
     *      - Revised pgm to make pick sequence mods unique to Bartlett.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: T&T Produce
     *
TNT A*    08/13/18  MLB  TNT
     *      - Per Hemant. Revised pgm to pick dept CLR aisles in seq:
     *        10-11, 50-55, 61-62, 71-72, 12-14, 31-33, 15, 40-45, 16,
     *        19, 17, 18, 99.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cotati Foods
     *
COT A*    09/25/18  MLB  COT
     *      - Per Hemant. Revised pgm to pick dept R ahead of depts
     *        D and F.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earls Organic Produce
     *
EOP A*    03/06/19  MLB  EOP
     *      - Per Hemant. Revised pgm to pick dept REF aisles in custom
     *        sequence.
EOPaA*    09/26/19  MLB  EOPa
     *      - Per Shane T. Revised pgm to pick locations C5-513, C5-515
     *        after C5-511-1 and before C5-238-1.
     *      - Moved CSO-001-1 before BAN-001-1. .
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
     *
CLDbA*    11/09/18  RBD  CLDb
     *      - Per Steve Di Zinnno, separated aisles S, SA, SB and SC
     *        and deleted aisle SS. Renumbered other aisles to allow
     *        room for resequencing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit Foods
     *
MRT A*    11/12/18  MLB  MRT
     *      - Per Hemant. Revised pgm to sequence, D, F, and R aisles
     *        per email. Will require mods to PFMT, OR400 and VOSELECT
     *        to setup use of LABEL32D since all depts picked in one
     *        pick zone.
MRTaA*    12/24/18  MLB  MRTa
     *      - Per Ginger. Revised pgm to sequence slots per Jeff H.
     *        email Dec 12, 2018
MRTbA*    01/28/19  NLK  MRTb
     *      - Revised per Jeff H from Prior List
MRTcA*    02/12/19  NLK  MRTc
     *      - Revised per Jeff H from Prior List
MRTdA*    02/15/19  NLK  MRTd
     *      - Revised to add ItemFLD file to grab Category for CHEM.
MRTeA*    06/19/19  MLB  MRTe
     *      - Revised to seq slots for dept D, aisle 82 at end of pick
     *        sequence. Per Jeff H. email dated 06.18.2019.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWT A*    03/08/19  MLB  SWT
     *      - Per Hemant. Revised pgm to pick dept FRESH ahead of dept
     *        DRY. Needs LABEL32D.
     *
SWTbA*    10/09/20  JCJ  SWTb
     *      - Changed LVL2 logic to include Rack level <10 for Dry
     *        instead of =10.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Y.Hata
     *
YHA A*    12/16/21  MLB  YHA
     *      - Revised pick sequence for dept CHL, aisles 24, 25 to be
     *        picked first in ascending sequence.
     *      - Revised to update pick sequence for dept CHL, aisles 26
     *        and 27 to pick side to side instead of all even, all odd
     *        Per Lester's email dated 10.25.21.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     FLABEL13   UF   E           K DISK
730dDF*ORKLBL   IF   E           K DISK
730dMFWORKLBLW  IF   E           K DISK
730dDf*abel     if   e           k disk    rename(lbrec:lbrec1)
730dMfLabelw    if   e           k disk    rename(lbrec:lbrec1)
EFCaAFPIRITEM   IF   E           K DISK
MRTdAFitemfld   IF   E           K DISK
510dAFSLOT2     IF   E           K DISK
DRYfAFRTEHED    IF   E           K DISK
510iAFoptions   if   e           k disk
700bAFworklbl8  UF   E           K Disk    Rename(LWREC:LWREC2)

500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*----------------------------------------------------------------
500 A
510bA /copy qcopysrc,id#andrews
500 A /copy qcopysrc,id#birite
500 A /copy qcopysrc,id#cheney
500bA /copy qcopysrc,id#cheneyo
500bA /copy qcopysrc,id#cheneyr
650 A */copy qcopysrc,id#cheneyg
CBI A /copy qcopysrc,id#cheneyp
640aA /copy qcopysrc,id#dierks
500cA /copy qcopysrc,id#isupply
500eA /copy qcopysrc,id#harbor
500fA /copy qcopysrc,id#ei
CTW A /copy qcopysrc,id#citywho
510cA /copy qcopysrc,id#gsc
510dA /copy qcopysrc,id#ellenbe
510fA /copy qcopysrc,id#tpc
CWDaA /copy qcopysrc,id#cashwa
520aA /copy qcopysrc,id#cdi
520dA /copy qcopysrc,id#palmer
520eA /copy qcopysrc,id#royal
530aA /copy qcopysrc,id#halsey
530cA /copy qcopysrc,id#fischer
FRF A /copy qcopysrc,id#frf
EFCaA /copy qcopysrc,id#eastlan
520gA /copy qcopysrc,id#jordano
DRY A /copy qcopysrc,id#dairyla
DRYgA /copy qcopysrc,id#drybron
DRY A /copy qcopysrc,id#dryhano
DRYeA *copy qcopysrc,id#dryla
DRYf  *copy qcopysrc,id#drycinc
DRYjA *copy qcopysrc,id#drysf
DRYkA /copy qcopysrc,id#dryqchi
KFS A /copy qcopysrc,id#kfs
ICBaA /copy qcopysrc,id#icb
SVLaA /copy qcopysrc,id#saval
HMWaA /copy qcopysrc,id#hmwagne
SFGaA /COPY QCOPYSRC,Id#sgc
SBR A /copy qcopysrc,id#sbr
CLDaA /copy qcopysrc,id#citylin
WIL A /copy qcopysrc,id#wil
JSLaA /copy qcopysrc,id#jsl
FPR A /copy qcopysrc,id#fpr
GLP A /copy qcopysrc,id#glp
PAN A /copy qcopysrc,id#pan
RNZ A /copy qcopysrc,id#renzi
ADF A /copy qcopysrc,id#adf
FGL A /copy qcopysrc,id#fgl
GRC A /copy qcopysrc,id#grc
TNT A /copy qcopysrc,id#tnt
COT A /copy qcopysrc,id#cot
EOP A /copy qcopysrc,id#eop
MRT A /copy qcopysrc,id#mrt
SWT A /copy qcopysrc,id#swt
YHA A /copy qcopysrc,id#yhata
YHA A /copy qcopysrc,id#yhaoahu

640cA*----------------------------------------------------------------
640cA*  DRI parameters
640cA*----------------------------------------------------------------
640cA
640cA /COPY *libl/qcopysrc,C#DRIPARMS
640cA
640cA*----------------------------------------------------------------
640cA*  Data Formats
640cA*----------------------------------------------------------------
640cA
640cA /COPY *libl/qcopysrc,C#Item
640cA
640cAD savever#        s                   like($itver#)
640cAD save$item       s                   like($item)
640cAD save$item2      s                   like($item2)

     *----------------------------------------------------------------
510iA*  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
510iA* Fields
     *
510iA*    OPHVY   -  Heavy items are greater than or equal to ...
     *
     * Data structure
     *
510iAD opdata          ds
510iAD  ophvy                 74     75  0

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

500 AD iflag           s               n
500gAD dummy           s                   like(lbloc)
500gAD side            s              1  0
730aAD softCoded       s               N
730bAD sqlstmtl        s           5000a   inz(' ')
520dAD temp1a          s              1
500cAD temp2a          s              2
700bAD UseWorkLbl      s               N
700bAD UseSingleLabel  s               N
730aA
730aA*----------------------------------------------------------
730aA*  Standard SQL variables and constants
730aA*----------------------------------------------------------
730aA
730aA /copy qcopysrc,c#stdsql
730aA /copy qcopysrc,c#stdvar
730aA
730aA*----------------------------------------------------------
730aA*  SQL record layouts referenced
730aA*----------------------------------------------------------
730aA
730aAD dfdrec        E Ds                  Extname(dfpickdtl)
730aAD dfprec        E Ds                  Extname(dfpickpsq)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
700bAC                   parm                    $ppbld            9
730bAc                   parm                    $label            7 0
730bAc                   parm                    $ids            200

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Define key for LABEL13 file.

     C     key13         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
700bA*  Define key for WORKLBL8 file.

700bAC     keyL8         klist
700bAC                   kfld                    $pwhse
700bAC                   kfld                    $prtid
510dA
510dA*  Define key for SLOT2 file.
510dA
510dAC     keysl2        klist
510dAC                   kfld                    lbwhse
510dAC                   kfld                    lbwhdp
510dAC                   kfld                    lbdisp

EFCAA
EFCAA*  Define key for PIRITEM
EFCAA
EFCAAC     keyitem       klist
EFCAAC                   kfld                    lbwhse
EFCAAC                   kfld                    lbitem
MRTdA
MRTdA*  Define key for PIRITEM
MRTdA
MRTdAC     keyitemfld    klist
MRTdAC                   kfld                    lbwhse
MRTdAC                   kfld                    lbitem
MRTdA
510iA*  Define key for OPTIONS file with whse

510iAC     opkey_whse    klist
510iAC                   kfld                    $pwhse
510iAC                   kfld                    opcode

700bA*  Check parms passed in to see if PrePalletBuild
700bAC                   If        %parms >= 3
730bAc                   if        $PPBLD <> '*SOFTPICK'
700bAC                   Eval      $PPBLD = 'PREPLTBLD'
700bAC                   Eval      UseWorkLbl = *On
730bAc                   else
730bAc                   eval      UseSingleLabel = *on
730bAc                   eval      $ids = '*NONE'
730bAc                   ENDIF
700bAC                   EndIf
730aA
730aA*
730aA*  Changed mainline.  Kept db reads in mainline
730aA*  but moved hard coded subroutine calls by customer
730aA*  in subroutine called originalMain.  With new
730aA*  soft coding now possible for seuqencing that is called
730aA*  when records exist
730aA*
730aA*  Loop through all labels for route.
730aA
700bAC                   Select
730bAC                   When      UseSingleLabel
730aA*  Do nothing since we will only process one label record
700bAC                   When      UseWorkLbl
700bAC     KeyL8         SetLL     Worklbl8
700bAC                   Other
     C     key13         SETLL     label13
700bAC                   EndSL
     C*
     C                   dow       forever = forever
700bAC                   Select
730aA*  Only reads one label when called from M29500.  This program
730aA*  allows user to test soft coding sequencing by returning all
730aA*  the id's applicable to data associated to that specific label
730bAc                   when      UseSingleLabel
730dDc**   $label        chain     label
730dM /free
730dM                    chain ($pwhse: $label) labelw;
730dM /end-free
730dMc                   if        not %found(labelw)
730dDc**   $label        chain     worklbl
730dM /free
730dM                    chain ($pwhse: $label) worklblw;
730dM /end-free
730dMc                   if        not %found(worklblw)
730bAc                   leave
730bAc                   else
730bAc                   exsr      $CopFlds
730bAc                   endif
730bAc                   endif
730bAc
700bAC                   When      UseWorkLbl
700bAC     KeyL8         ReadE     Worklbl8
700bAC                   if        %eof
700bAC                   leave
700bAC                   Else
700bAC                   ExSR      $Copflds
700bAC                   Endif

700bAC                   Other
     C     key13         reade     label13
     C                   if        %eof
     C                   leave
     C                   endif
700bAC                   EndSL

730aA*      Either execute Softcode to populate sequence or original hardcode
730aAc                   if        softCoded
730aAc                   exsr      softCode
730aAc                   else
730aAc                   exsr      originalMain
730aAc                   endif
730aA*
500 AC                   if        iflag = *on
500 AC                   iter
500 AC                   endif

700bAC                   Select
730bAc                   when      UseSingleLabel
730aA*      only processes the one label sent
730bAc                   leave
700bAC                   When      UseWorkLbl
700bAC                   Eval      LWLVL2 = LBLVL2
700bAC                   update(e) lwrec2

700bAC                   Other
     C                   update(e) lbrec
700bAC                   EndSL

     C                   enddo

     *  Bye, Bye

     C                   eval      *inlr = *on
     C                   return

730aA*----------------------------------------------------------------
730aA*  originalMain  -  Original Mainline
730aA*----------------------------------------------------------------
730aA
730aAC     originalMain  begsr
500 A
500 A*  Get client id.
500 A
500 AC                   call      'GETCLIENT'
500 AC                   parm                    client           10
500bAC                   parm                    clientloc        10
500 A
500 A*  If client doesn't use special sequencing, then get out.
500 A
500 AC                   if        client <> birite
510bAC                             and client <> andrews
520aAC                             and client <> cdi
500 AC                             and client <> cheney
DRY AC                             and client <> dairyland
DRY AC                             and clientloc <> dryhanover
DRYeAC                             and clientloc <> drylosangeles
DRYfAC                             and clientloc <> drycin
DRYjAC                             and clientloc <> drysanfran
DRYkAC                             and clientloc = dryqznchicago
DRYmAC                             and clientloc = drytoronto
500cAC                             and client <> isupply
510hDC**                           and client <> harbor
500fAC                             and client <> ei
510cAC                             and client <> gsc
510dAC                             and client <> ellenbee
510fAC                             and client <> tpc
CWDaAC                             and client <> cashwa
520cAC                             and client <> citywholesale
520dAC                             and client <> palmer
520eAC                             and client <> royal
SVL AC                             and client <> saval
530aAC                             and client <> halsey
530cAC                             and client <> fischr
FRF AC                             and client <> frf
520gAC                             and client <> jordanos
640aAC                             and client <> dierks
EFCaAC                             and client <> eastland
500 AC                             and client <> 'BFCTEST'
CTW AC                             and client <> citywholesale
KFS AC                             and client <> kellys
SGCaAC                             and client <> sgc
ICBaAC                             and client <> icb
SBR AC                             and client <> SBertram
CLDaAC                             and client <> cityLine
WIL AC                             and client <> WillFoods
JSLaAC                             and client <> JSilvert
FPR AC                             and client <> FoodPro
GLP AC                             and client <> greenleaf
PAN AC                             and client <> Panos
RNZ AC                             and client <> Renzi
ADF AC                             and client <> AandDFoods
FGL AC                             and client <> FoodsGalore
GRC AC                             and client <> Greco
TNT AC                             and client <> TnTProduce
COT AC                             and client <> Cotati
EOP AC                             and client <> EarlsOrganic
MRT AC                             and client <> Merit
SWT AC                             and client <> SWT
YHA AC                             and client <> YHata
730aDC*                  goto      bottom
730aAC                   eval      *inlr = *on
730aAC                   return
500 AC                   endif
500 A
500 A*    Call approriate sequence routine.
500 A
500 AC                   select
510bA
510bAC                   when      client = andrews
510bAC                   exsr      andrewsseq
500 A
500 AC                   when      client = birite
500 AC                   exsr      biriteseq
CWDa
CWDa C                   when      client = cashwa
CWDa C                   exsr      cashwaseq
520aA
JSLa C                   when      client = JSilvert
JSLa C                   exsr      jslseq
JSLa
520aAC                   when      client = cdi
520aAC                   exsr      cdiseq
500bA
500bAC                   when      client = cheney
500bAC                             and clientloc = cheneyocala
500bAC                   exsr      cheneyseqocala
650 A
650 AC                   when      client = cheney
650 AC                             and clientloc = cbigwb
650 AC                   exsr      cheneyseqgwb
CBI A
CBI AC                   when      client = cheney
CBI AC                             and clientloc = cheneypntgr
CBI AC                   exsr      cheneyseqpnt
CBIeA
CBIeAC                   when          client = cheney
CBIeAC                             and clientloc = cbigr
CBIeAC                   exsr      cheneyseqpdgrn
CBIeA
CBIeAC                   when          client = cheney
CBIeAC                             and clientloc = cbigo
CBIeAC                   exsr      cheneyseqpdgld
CBIeA
CBIeAC                   when          client = cheney
CBIeAC                             and clientloc = cbist
CBIeAC                   exsr      cheneyseqpdsta
CBIjA
CBIjAC                   when          client = cheney
CBIjAC                             and clientloc = cbimlk
CBIjAC                   exsr      cheneyseqmlk
500 A
500 AC                   when      client = cheney
500 AC                   exsr      cheneyseq
520aA
700aAC                   when      client = cityline
700aAC                   exsr      citylineseq
520aA
520cAC                   when      client = citywholesale
520cAC                   exsr      citywholeseq
DRY A
DRY AC                   when          client = dairyland
DRY AC                             and clientloc = dryhanover
DRY AC                   exsr      dairylandseq
DRYeAC
DRYeAC                   when          client = dairyland
DRYeAC                             and clientloc = drylosangeles
DRYeAC                   exsr      dryseqla
DRYfAC
DRYfAC                   when          client = dairyland
DRYfAC                             and clientloc = drycin
DRYfAC                   exsr      dryseqcinc
DRYgAC                   when          client = dairyland
DRYgAC                             and clientloc = drybronx
DRYgAC                   exsr      dryseqbronx
DRYjAC                   when          client = dairyland
DRYjAC                             and clientloc = drysanfran
DRYjAC                   exsr      dryseqsanfran
DRYkAC                   when          client = dairyland
DRYkAC                             and clientloc = dryqznchicago
DRYkAC                   exsr      dryseqqznchi
DRYmA
DRYmAC                   when          client = dairyland
DRYmAC                             and clientloc = drytoronto
DRYmAC                   exsr      dryseqtoronto
640aA
640aAC                   when      client = dierks
640aAC                   exsr      dierksseq
510dA
510dAC                   when      client = ellenbee
510dAC                   exsr      ellenbeeseq
500fA
500fAC                   when      client = ei
500fAC                   exsr      eiseq
530cA
530cAC                   when      client = fischr
530cAC                   exsr      fshseq
FRF A
FRF AC                   when      client = frf
FRF AC                   exsr      frfseq
510cA
510cAC                   when      client = gsc
510cAC                   exsr      gscseq
530aA
530aAC                   when      client = halsey
530aAC                   exsr      halseyseq
500eA
500eAC                   when      client = harbor
500eAC                   exsr      harborseq
640bA
640bAC                   when      client = icb
640bAC                   exsr      icbseq
500cA
500cAC                   when      client = isupply
500cAC                   exsr      isupplyseq
520dA
520dAC                   when      client = palmer
520dAC                   exsr      palmerseq
510fA
510fAC                   when      client = tpc
510fAC                   exsr      tpcseq
EFCaA
EFCaAC                   when      client = eastland
EFCaAC                   exsr      efcseq
520eA
520gAC                   when      client = jordanos
JORbDC**                 exsr      jorseq
520eA
520eAC                   when      client = royal
520eAC                   exsr      royalseq
520eA
SVL AC                   when      client = saval
SVL AC                   exsr      svlseq
500 A
500 AC                   when      client = 'BFCTEST'
500 AC                   exsr      bfctestseq
500 A
CTW A
CTW AC                   when      client = citywholesale
CTW AC                   exsr      citywhoseq
KFS A
KFS AC                   when      client = kellys
KFS AC                   exsr      kellysseq
SGCaA
SGCaAC                   when      client = sgc
SGCaAC                   exsr      sgcseq
SBR A
SBR AC                   when      client = SBertram
SBR AC                   exsr      SBertramSeq
WIL A
WIL AC                   when      client = WillFoods
WIL AC                   exsr      WillFoodseq
PAN A
PAN AC                   when      client = Panos
PAN AC                   exsr      Panosseq
FPR A
FPR AC                   when      client = FoodPro
FPR AC                   exsr      FoodProseq
RNZ A
RNZ AC                   when      client = renzi
RNZ AC                   exsr      renziseq
ADF A
ADF AC                   when      client = AandDFoods
ADF AC                   exsr      ADFoodsseq
FGL A
FGL AC                   when      client = FoodsGalore
FGL AC                   exsr      FGLseq
GRC A
GRC AC                   when      client = Greco
GRCbAC                             and clientloc = Grecobar
GRC AC                   exsr      GRCseq
TNT A
TNT AC                   when      client = TnTProduce
TNT AC                   exsr      TNTseq
COT A
COT AC                   when      client = Cotati
COT AC                   exsr      COTseq
EOP A
EOP AC                   when      client = EarlsOrganic
EOP AC                   exsr      EOPseq
MRT A
MRT AC                   when      client = Merit
MRT AC                   exsr      MRTseq
SWT A
SWT AC                   when      client = SWT
SWT AC                   exsr      SWTseq
YHA A
YHA AC                   when      client = YHata
YHA AC                             and clientloc = yhaoahu
YHA AC                   exsr      YHataseq
CTW A
500 AC                   endsl

730aAc                   endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*          SUBROUTINES IN ALPHABETICAL ORDER
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

510bA*----------------------------------------------------------------
510bA*  andrewsseq  -  Special sequencing for Andrews
510bA*----------------------------------------------------------------
510bA
510bAC     andrewsseq    begsr
510b C                   eval      iflag = *off
510b
510b *    Only update REF type 'O' labels.
510b
510b C                   if        lbwhdp <> 'REF'
510b C                             or lbtype <> 'O'
510b C                   eval      iflag = *on
510b C                   goto      endandrews
510b C                   endif
510b
510b *    Set up custom sequence for use with LABEL32C.
510b
510b C                   select
510b
510b *      Pick aisle 19 first.
510b
510b C                   when      lbaisl = ' 19'
510b C                   eval      lblvl2 = 1
510b
510b *      Then everything else.
510b
510b *        Note, by setting everything else to 50, the normal Aisle,
510b *        Picking Seq. order takes affect. Also, by using 50, the
510b *        possibility is left open to assign an aisle to be picked last
510b
510b C                   other
510b C                   eval      lblvl2 = 50
510b
510b C                   endsl
510b
510b C     endandrews    endsr

500 A*----------------------------------------------------------------
500 A*  bfctestseq  -  Special sequencing for BFCTEST
500 A*----------------------------------------------------------------
500 A
500 AC     bfctestseq    begsr
     C                   eval      iflag = *off

     *    Only update DRY type 'O' labels.

     C                   if        lbwhdp <> 'DRY'
     C                             or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endbfctest
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle T first.

     C                   when      lbaisl = ' DC'
     C                   eval      lblvl2 = 1

     C                   when      lbaisl = ' DB'
     C                   eval      lblvl2 = 2

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endbfctest    endsr

500 A*----------------------------------------------------------------
500 A*  biriteseq  -  Special sequencing for BiRite
500 A*----------------------------------------------------------------
500 A
500 AC     biriteseq     begsr
     C                   eval      iflag = *off

     *    Only update CLR type 'O' labels.

     C                   if        lbwhdp <> 'CLR'
     C                             or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endbirite
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

510gM*      Pick aisle U first.

510gMC                   when      lbaisl = '  U'
510gMC                   eval      lblvl2 = 1

510gM*      Pick aisle W second.

510gMC                   when      lbaisl = '  W'
510gMC                   eval      lblvl2 = 2

510gM*      Pick aisle V third.

510gMC                   when      lbaisl = '  V'
510gMC                   eval      lblvl2 = 3

     *      Pick aisle T fourth.

     C                   when      lbaisl = '  T'
510bMC                   eval      lblvl2 = 4

510bM*      Pick aisle S fifth.

510bMC                   when      lbaisl = '  S'
510bMC                   eval      lblvl2 = 5

510bM*      Pick aisle R sixth.

510bMC                   when      lbaisl = '  R'
510bMC                   eval      lblvl2 = 6

510bM*      Pick aisle Q seventh.

510bMC                   when      lbaisl = '  Q'
510bMC                   eval      lblvl2 = 7

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endbirite     endsr
CLDaA*----------------------------------------------------------------
CLDaA*  citylineseq  -  Special sequencing for City Line
CLDaA*----------------------------------------------------------------
CLDaA
CLDaAC     citylineseq   begsr
     C                   eval      iflag = *off

     *    Only update CLR type 'O' labels.

     C                   if        lbwhdp <> 'FRZ'
     C                             or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endcityline
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle R first.

     C                   when      lbaisl = '  R'
     C                   eval      lblvl2 = 1

     *      Pick aisle S second.

CLDbDC**                 when      lbaisl = '  S' or
CLDbMC                   when      lbaisl = '  S'
CLDbDC**                           lbaisl = ' SA' or
CLDbDC**                           lbaisl = ' SB' or
CLDbDC**                           lbaisl = ' SC' or
CLDbDC**                           lbaisl = ' SS'
CLDbDC**                 eval      lblvl2 = 2
CLDbMC                   eval      lblvl2 = 5

CLDbAC                   when      lbaisl = ' SA'
CLDbAC                   eval      lblvl2 = 10
CLDbAC                   when      lbaisl = ' SB'
CLDbAC                   eval      lblvl2 = 15
CLDbAC                   when      lbaisl = ' SC'
CLDbAC                   eval      lblvl2 = 20

     *      Pick aisle T third.

     C                   when      lbaisl = '  T'
CLDbDC**                 eval      lblvl2 = 3
CLDbMC                   eval      lblvl2 = 25

     *      Pick aisle U fourth.

     C                   when      lbaisl = '  U'
CLDbDC**                 eval      lblvl2 = 4
CLDbMC                   eval      lblvl2 = 30

     *      Pick aisle V fifth.

     C                   when      lbaisl = '  V'
CLDbDC**                 eval      lblvl2 = 5
CLDbMC                   eval      lblvl2 = 35

     *      Pick aisle WW sixth.

     C                   when      lbaisl = ' WA'
CLDbDC**                 eval      lblvl2 = 6
CLDbMC                   eval      lblvl2 = 40

     *      Pick aisle W seventh.

     C                   when      lbaisl = '  W'
CLDbDC**                 eval      lblvl2 = 7
CLDbMC                   eval      lblvl2 = 45


     *      Pick aisle X eigthth.

     C                   when      lbaisl = '  X'
CLDbDC**                 eval      lblvl2 = 8
CLDbMC                   eval      lblvl2 = 50


     *      Pick aisle YY ninth.

     C                   when      lbaisl = ' YA'
CLDbDC**                 eval      lblvl2 = 9
CLDbMC                   eval      lblvl2 = 55

     *      Pick aisle Y tenth.

     C                   when      lbaisl = '  Y'
CLDbDC**                 eval      lblvl2 = 10
CLDbMC                   eval      lblvl2 = 60

     *      Then everything else.

CLDbM*        Note, by setting everything else to 80, the normal Aisle,
CLDbM*        Picking Seq. order takes affect. Also, by using 80, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
CLDbDC**                 eval      lblvl2 = 50
CLDbMC                   eval      lblvl2 = 80

     C                   endsl

     C     endcityline   endsr


CWDaA*----------------------------------------------------------------
CWDaA*  cashwaseq  -  Special sequencing for Cash-WA
CWDaA*----------------------------------------------------------------
CWDaA
CWDaAC     cashwaseq     begsr
     C                   eval      iflag = *off

     *    Sequencing for Aberdeen.

     C                   if        clientloc <> 'ABERDEEN'
     C                   goto      endcashwa
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle 42first.

CWDcDC*                  when      lbwhdp = 'CLR  ' and lbaisl = ' 42'
CWDcDC*                  eval      lblvl2 = 5

     *      Pick aisle 41 second.

CWDcDC*                  when      lbwhdp = 'CLR  ' and lbaisl = ' 41'
CWDcDC*                  eval      lblvl2 = 10

      *      Pick aisle 40 third.

CWDcDC*                  when      lbwhdp = 'CLR  ' and lbaisl = ' 40'
CWDcDC*                  eval      lblvl2 = 15


     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

CWDa C     endcashwa     endsr

JSLaA*----------------------------------------------------------------
JSLaA*  JSLseq  -  Special sequencing for Julius Silvert
JSLaA*----------------------------------------------------------------
JSLaA
JSLaAC     jslseq        begsr
     C                   eval      iflag = *off


     *    Only update Cooler type 'O' labels.

JSLbDC*                  if        lbwhdp <> 'R    '
JSLdDC***                if        lbwhdp = 'F    '
JSLdDC***                          or lbtype <> 'O'
JSLdMC                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endjsl
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle 20

     C                   when      lbwhdp = 'R    ' and lbaisl = ' 20'
     C                   eval      lblvl2 = 5

JSLdA*      Pick Freezer
JSLdA
JSLdAC                   when      lbwhdp = 'F    ' and lbaisl = ' 11'
JSLdAC                             and lbloc >= 200 and lbloc <= 221
JSLdAC                   eval      lblvl2 = 10
JSLdA
JSLdAC                   when      lbwhdp = 'F    ' and lbaisl = ' 12'
JSLdAC                             and lbloc >= 300 and lbloc <= 348
JSLdAC                   eval      lblvl2 = 15
JSLdA
JSLdAC                   when      lbwhdp = 'F    ' and lbaisl = ' 11'
JSLdAC                             and lbloc >= 225 and lbloc <= 254
JSLdAC                   eval      lblvl2 = 20
JSLdA
JSLdAC                   when      lbwhdp = 'F    ' and lbaisl = ' 10'
JSLdAC                             and lbloc >= 100 and lbloc <= 118
JSLdAC                   eval      lblvl2 = 25
JSLdA
JSLdAC                   when      lbwhdp = 'F    ' and lbaisl = ' 13'
JSLdAC                   eval      lblvl2 = 30

JSLcA*      Then DRY
JSLcA
JSLcAC                   when      lbwhdp = 'D    '
JSLcAC                   eval      lblvl2 = 35
JSLcA
JSLcA*      Then pick aisle 73
JSLcA
JSLcAC                   when      lbwhdp = 'R    ' and lbaisl = ' 73'
JSLcAC                   eval      lblvl2 = 40
JSLcA*      Then pick aisle 72
JSLcA
JSLcAC                   when      lbwhdp = 'R    ' and lbaisl = ' 72'
JSLcAC                   eval      lblvl2 = 41
JSLcA*      Then pick aisle 71
JSLcA
JSLcAC                   when      lbwhdp = 'R    ' and lbaisl = ' 71'
JSLcAC                   eval      lblvl2 = 42
JSLcD
JSLcA*      Then pick aisle 70
JSLcA
JSLcAC                   when      lbwhdp = 'R    ' and lbaisl = ' 70'
JSLcAC                   eval      lblvl2 = 43
JSLcD
JSLcM
JSLcM*      Then pick aisle 30
JSLcM
JSLcMC                   when      lbwhdp = 'R    ' and lbaisl = ' 30'
JSLcMC                   eval      lblvl2 = 44
JSLcM
JSLcM*      Then pick aisle 31
JSLcM
JSLcMC                   when      lbwhdp = 'R    ' and lbaisl = ' 31'
JSLcMC                   eval      lblvl2 = 45
JSLcM
JSLcM*      Then pick aisle 32
JSLcM
JSLcMC                   when      lbwhdp = 'R    ' and lbaisl = ' 32'
JSLcMC                   eval      lblvl2 = 46
JSLcA*      Then pick aisle 74
JSLcA
JSLcAC                   when      lbwhdp = 'R    ' and lbaisl = ' 74'
JSLcAC                   eval      lblvl2 = 47


     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endjsl        endsr

520aA*----------------------------------------------------------------
520aA*  cdiseq  -  Special sequencing for Customized Distribution
520aA*----------------------------------------------------------------
520aA
520aAC     cdiseq        begsr

     *    Only update type 'O' labels.

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endcdi
     C                   endif
640cA
640cA*    Get item information.
640cA
640cAC                   eval      savever# = $itver#
640cAC                   clear                   $item
640cAC                   clear                   $item2
640cAC                   eval      $itver# = savever#
640cA
640cAC                   eval      $itwhse   = lbwhse
640cAC                   eval      $ititem   = lbitem
640cA
640cAC                   eval      $dricommand = '*ITEM'
640cAC                   eval      $drisubcmd  = '%GETMAIN'
640cAC                   eval      $drisys2upd = 'D'
640cAC                   exsr      zzzdricop

     *    Set up custom sequence for use with LABEL32C.

     C                   select
640cA
640cA*      Always pick CHEM items first.
640cA
640cAC                   when      $itdesg = 'CHEM'
CDIbAC                             and clientloc = 'CDIATL'
CDIgDC*                  eval      lblvl2 = 2
CDIgMC                   eval      lblvl2 = 1

     *      Freezer
     *        Pick aisle 4 - 7 in descending aisle order.

CDI DC**                 when      lbwhdp = 'FRZ'
CDI DC**                 select
CDI DC**                 when      lbaisl = '  7'
CDI DC**                 eval      lblvl2 = 1
CDI DC**                 when      lbaisl = '  6'
CDI DC**                 eval      lblvl2 = 2
CDI DC**                 when      lbaisl = '  5'
CDI DC**                 eval      lblvl2 = 3
CDI DC**                 when      lbaisl = '  4'
CDI DC**                 eval      lblvl2 = 4
CDI DC**                 endsl

     *      Dry
     *        Pick aisle 11 - 18 in descending aisle order.

     C                   when      lbwhdp = 'DRY'
CDIbAC                             and clientloc = 'CDIATL'
     C                   select
CDIcAC                   when      lbaisl = ' 19'
CDIhDC*                  eval      lblvl2 = 2
CDIhMC                   eval      lblvl2 = 1
CDIhA*
CDIhAC                   when      lbaisl = ' 25'
CDIhAC                   eval      lblvl2 = 2
CDIhA*
CDIhAC                   when      lbaisl = ' 23'
CDIhAC                   eval      lblvl2 = 3
CDIhA*
     C                   when      lbaisl = ' 18'
640cDC*                  eval      lblvl2 = 2
CDIhMC                   eval      lblvl2 = 4
     C                   when      lbaisl = ' 17'
640cDC*                  eval      lblvl2 = 3
CDIhMC                   eval      lblvl2 = 5
     C                   when      lbaisl = ' 16'
640cDC*                  eval      lblvl2 = 4
CDIhMC                   eval      lblvl2 = 6
     C                   when      lbaisl = ' 15'
640cDC*                  eval      lblvl2 = 5
CDIhMC                   eval      lblvl2 = 7
     C                   when      lbaisl = ' 14'
640cDC*                  eval      lblvl2 = 6
CDIhMC                   eval      lblvl2 = 8
     C                   when      lbaisl = ' 13'
640cDC*                  eval      lblvl2 = 7
CDIhMC                   eval      lblvl2 = 9
     C                   when      lbaisl = ' 12'
640cDC*                  eval      lblvl2 = 8
CDIhMC                   eval      lblvl2 = 10
     C                   when      lbaisl = ' 11'
640cDC*                  eval      lblvl2 = 9
CDIhMC                   eval      lblvl2 = 11
     C                   endsl
CDIbA*      Cooler
CDIbA*        Pick aisle 8 - 10 in descending aisle order.

CDIbAC                   when      lbwhdp = 'CLR'
CDIbAC                             and clientloc = 'CDIATL'
CDIbAC                   select
CDIbAC                   when      lbaisl = ' 10'
CDIiDC*                  eval      lblvl2 = 2
CDIiMC                   eval      lblvl2 = 3
CDIbAC                   when      lbaisl = ' 09'
CDIiDC*                  eval      lblvl2 = 3
CDIiMC                   eval      lblvl2 = 2
CDIbAC                   when      lbaisl = ' 08'
CDIiDC*                  eval      lblvl2 = 4
CDIiMC                   eval      lblvl2 = 1
CDIbAC                   endsl

CDIdA*      Dry
CDIdA*        Pick aisle 10 before aisle 9
CDIdA
CDIdAC                   when      lbwhdp = 'DRY'
CDIdAC                             and clientloc = 'CDIJACKMS'
CDIdAC                   select
CDIeDC*                  when      lbaisl < ' 09'
CDIfDC*                  when          lbaisl >= ' 01'
CDIfDC*                            and lbaisl <= ' 02'
CDIfMC                   when          lbaisl >= ' 05'
CDIeAC                             and lbaisl <= ' 11'
CDIdAC                   eval      lblvl2 = 2
CDIeA*
CDIeDC*                  when      lbaisl = ' 10'
CDIeMC                   when      lbaisl = ' 04'
CDIdAC                   eval      lblvl2 = 3
CDIeA*
CDIeDC*                  when      lbaisl = ' 09'
CDIeMC                   when      lbaisl = ' 03'
CDIeMC                   eval      lblvl2 = 4
CDIfA*
CDIfAC                   when      lbaisl = ' 02'
CDIfAC                   eval      lblvl2 = 5
CDIfA*
CDIfAC                   when          lbaisl >= ' 50'
CDIfAC                             and lbaisl <= ' 51'
CDIfAC                   eval      lblvl2 = 6
CDIfA*
CDIfAC                   when      lbaisl = ' 01'
CDIfAC                   eval      lblvl2 = 7
CDIfA*
CDIdAC                   endsl

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endcdi        endsr

520cA*----------------------------------------------------------------
520cA*  citywholeseq  -  Special sequencing for City Wholesale
520cA*----------------------------------------------------------------
520cA
520cAC     citywholeseq  begsr
     C                   eval      iflag = *off

     *    Only update type 'O' labels.

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endcitywhol
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle 101 first.

     C                   when      lbaisl = '101'
     C                   eval      lblvl2 = 1

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endcitywhol   endsr
KFS A
KFS A*----------------------------------------------------------------
KFS A*  kellysseq -  Special sequencing for Kelly's Foods
KFS A*----------------------------------------------------------------
KFS A
KFS AC     kellysseq     begsr
KFS AC                   eval      iflag = *off
KFS A
KFS A*    Only update type 'O' labels.
KFS A
KFS AC                   if        lbtype <> 'O'
KFS AC                   eval      iflag = *on
KFS AC                   goto      endkellys
KFS AC                   endif
KFS A
KFS A*    Set up custom sequence for use with LABEL32C.
KFS A
KFS AC                   select
KFS A
KFS A*      Pick aisle 101 first.
KFS A
KFS AC                   when      lbwhdp = 'REF'
KFS AC                   select
KFS AC                   when      lbaisl = ' CH'
KFS AC                   eval      lblvl2 = 1
KFS AC                   when      lbaisl = ' CF'
KFS AC                   eval      lblvl2 = 3
KFS AC                   when      lbaisl = ' CE'
KFS AC                   eval      lblvl2 = 5
KFS AC                   when      lbaisl = ' CD'
KFS AC                   eval      lblvl2 = 7
KFS AC                   when      lbaisl = ' CC'
KFS AC                   eval      lblvl2 = 9
KFS AC                   when      lbaisl = ' CA'
KFS AC                   eval      lblvl2 = 11
KFS AC                   other
KFS AC                   eval      lblvl2 = 50
KFS AC                   endsl
KFS A
KFS A*      Then everything else.
KFS A
KFS A*        Note, by setting everything else to 50, the normal Aisle,
KFS A*        Picking Seq. order takes affect. Also, by using 50, the
KFS A*        possibility is left open to assign an aisle to be picked last
KFS A
KFS AC                   other
KFS AC                   eval      lblvl2 = 50
KFS A
KFS AC                   endsl
KFS A
KFS AC     endkellys     endsr

GLP A
GLP A*----------------------------------------------------------------
GLP A*  greenleafseq -  Special sequencing for Greenleaf Produce
GLP A*----------------------------------------------------------------
GLP A
GLP AC     greenleafseq  begsr
GLP AC                   eval      iflag = *off
GLP A
GLP A*    Only update type 'O' labels.
GLP A
GLP AC                   if        lbtype <> 'O'
GLP AC                   eval      iflag = *on
GLP AC                   goto      endgreenleaf
GLP AC                   endif
GLP A
GLPaA*    Set up custom sequence for use with LABEL32V.
GLPaA*    All departments are picked in single pick zone.
GLPaA
GLPaAC                   select
GLPaA
GLPaA*------------------------------------------------
GLPaA*      Pick aisle sequencing for Warehouse.
GLPaA
GLPaAC                   when      lbaisl = ' 10'
GLPaAC                   eval      lblvl2 = 5
GLPaA*
GLPaAC                   when      lbaisl = ' 11'
GLPaAC                   eval      lblvl2 = 10
GLPbA*
GLPbAC                   when      lbaisl = ' 12'
GLPbAC                   eval      lblvl2 = 12
GLPaA*
GLPaAC                   when      lbaisl = ' 20'
GLPaAC                   eval      lblvl2 = 15
GLPaA*
GLPaAC                   when      lbaisl = ' 21'
GLPaAC                   eval      lblvl2 = 20
GLPaA*
GLPaAC                   when      lbaisl = ' 30'
GLPaAC                   eval      lblvl2 = 25
GLPaA*
GLPaAC                   when      lbaisl = ' 31'
GLPaAC                   eval      lblvl2 = 30
GLPaA*
GLPaAC                   when      lbaisl = ' 70'
GLPaAC                   eval      lblvl2 = 35
GLPaA*
GLPaAC                   when      lbaisl = ' 71'
GLPaAC                   eval      lblvl2 = 40
GLPaA*
GLPaAC                   when      lbaisl = ' 72'
GLPaAC                   eval      lblvl2 = 45
GLPaA*
GLPaAC                   when      lbaisl = ' 60'
GLPaAC                   eval      lblvl2 = 50
GLPaA*
GLPaAC                   when      lbaisl = ' 61'
GLPaAC                   eval      lblvl2 = 55
GLPaA*
GLPaAC                   when      lbaisl = ' 62'
GLPaAC                   eval      lblvl2 = 60
GLPaA*
GLPaA*      Then everything else.
GLPaA
GLPaA*        Note, by setting everything else to 80, the normal Aisle,
GLPaA*        Picking Seq. order takes affect. Also, by using 80, the
GLPaA*        possibility is left open to assign an aisle to be picked last
GLPaA
GLPaAC                   other
GLPaAC                   eval      lblvl2 = 80
GLPaA
GLPaAC                   endsl
GLP A
GLP AC     endgreenleaf  endsr

500 A*----------------------------------------------------------------
500bM*  cheneyseq  -  Special sequencing for Cheney Bros. - Default
500 A*----------------------------------------------------------------
500 A
500 AC     cheneyseq     begsr
     C                   eval      iflag = *off

500bD***  Only update DRY type 'O' labels.
500bM*    Only update DRY and CLR labels.

     C                   if        lbwhdp <> 'DRY'
500bAC                             and lbwhdp <> 'CLR'
500bDC**                           or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endcheney
     C                   endif
500bA
500bA*    Only update type 'O' labels.
500bA
500bAC                   if        lbtype <> 'O'
500bAC                   eval      iflag = *on
500bAC                   goto      endcheney
500bAC                   endif
500bA
500bA*    Retrieve corresponding WORKLBL record.
500bA
700bAC                   If        UseWorkLbl = *Off
730dDC**   lblbl#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lblbl#) worklblw;
730dM /end-free
500bAC                   if        not %found
500bAC                   eval      lwszon = *blanks
500bAC                   endif
700bAC                   EndIF

     *    Update LBLVL2 field, which will set the picking order in LABEL32C

     C                   select

500gAC                   when      lwszon = 'PRDPIR'
500gAC     lbloc         div       2             dummy
500gAC                   mvr                     side
500gAC                   if        side = 0
500gAC                   eval      lblvl2 = 1
500gAC                   else
500gAC                   eval      lblvl2 = 2
500gAC                   endif

500bAC                   when      lwszon = 'PRD' and lwwhdp = 'DRY'
500bAC                   eval      lblvl2 = 1

500bAC                   when      lwszon = 'PRD' and lwwhdp = 'CLR'
500bAC                   eval      lblvl2 = 2

500bAC                   when      lwszon = 'PRD'
500bAC                   eval      lblvl2 = 99

500bAC                   when      lwszon = 'CLR'
500bAC*           do not update CLR slot if not in PRD zone.

     C                   when      lbaisl < ' DF'
     C                   eval      lblvl2 = 1

     C                   when      lbaisl = ' DF'
417aMC                             and lbloc >= 98  and lbloc <= 218
417aDC**                           and lbloc >= 101 and lbloc <= 218
     C                   eval      lblvl2 = 2

     C                   when      lbaisl = ' DG'
     C                             and lbloc >= 309 and lbloc <= 428
     C                   eval      lblvl2 = 3

     C                   when      lbaisl = ' DH'
     C                             and lbloc >= 101 and lbloc <= 218
     C                   eval      lblvl2 = 4

     C                   when      lbaisl = ' DF'
510 DC*                            and lbloc >= 221 and lbloc <= 286
510 MC                             and lbloc >= 219 and lbloc <= 286
     C                   eval      lblvl2 = 5

     C                   when      lbaisl = ' DK'
530 D ***                          and lbloc >= 200 and lbloc <= 256
530 MC                             and lbloc >= 200 and lbloc <= 243
     C                   eval      lblvl2 = 6

530 AC                   when      lbaisl = ' DK'
530 AC                             and lbloc >= 246 and lbloc <= 260
530 AC                   eval      lblvl2 = 8

     C                   when      lbaisl = ' DL'
     C                             and lbloc >= 302 and lbloc <= 341
530 D ***                eval      lblvl2 = 7
530 MC                   eval      lblvl2 = 9

     C                   when      lbaisl = ' DM'
     C                             and lbloc >= 400 and lbloc <= 456
530 D ***                eval      lblvl2 = 8
530 MC                   eval      lblvl2 = 10

     C                   when      lbaisl = ' DN'
     C                             and lbloc >= 495 and lbloc <= 569
530 D ***                eval      lblvl2 = 9
530 MC                   eval      lblvl2 = 11

     C                   when      lbaisl = ' DF'
     C                             and lbloc >= 287 and lbloc <= 432
530 D ***                eval      lblvl2 = 10
530 MC                   eval      lblvl2 = 12

     C                   other
     C                   eval      lblvl2 = 99

     C                   endsl

     C     endcheney     endsr

500bA*----------------------------------------------------------------
500bA*  cheneyseqocala -  Special sequencing for Cheney Bros. Ocala
500bA*----------------------------------------------------------------
500bA
500bAC     cheneyseqocalabegsr
     C                   eval      iflag = *off

     *    Only update DRY and CLR labels.

     C                   if        lbwhdp <> 'DRY'
     C                             and lbwhdp <> 'CLR'
     C                   eval      iflag = *on
     C                   goto      endcheneyocala
     C                   endif

     *    Only update type 'O' labels.

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endcheneyocala
     C                   endif

     *    Retrieve corresponding WORKLBL record.

730dDC**   lblbl#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lblbl#) worklblw;
730dM /end-free
     C                   if        not %found
     C                   eval      lwszon = *blanks
     C                   endif

     *    Update LBLVL2 field, which will set the picking order in LABEL32C

     C                   select

500hA*      Produce

     C                   when      lwszon = 'PRD' and lwwhdp = 'DRY'
     C                   eval      lblvl2 = 1

     C                   when      lwszon = 'PRD' and lwwhdp = 'CLR'
     C                   eval      lblvl2 = 2

     C                   when      lwszon = 'PRD'
     C                   eval      lblvl2 = 99

500hA*      CLR

500hAC                   when      lbaisl = ' CA'
500hAC                             and lbloc <= 188
500hAC                   eval      lblvl2 = 1

500hAC                   when      lbaisl = ' CB'
500hAC                             and lbloc >= 593
500hAC                   eval      lblvl2 = 2

500hAC                   when      lbaisl = ' CC'
500hAC                             and lbloc <= 186
500hAC                   eval      lblvl2 = 3

500hAC                   when      lbaisl = ' CA'
500hAC                             and lbloc > 188
500hAC                   eval      lblvl2 = 4

500hAC                   when      lbaisl = ' CB'
500hAC                             and lbloc <= 580
500hAC                   eval      lblvl2 = 5

500hAC                   when      lbaisl = ' CC'
500hAC                             and lbloc > 186
500hAC                   eval      lblvl2 = 6

640 AC                   when      lbaisl = ' CD'
640 AC                   eval      lblvl2 = 7

640 AC                   when      lbaisl = ' CE'
640 AC                   eval      lblvl2 = 8

640 AC                   when      lbaisl = ' CF'
640 AC                   eval      lblvl2 = 9

640 AC                   when      lbaisl = ' CG'
640 AC                   eval      lblvl2 = 10

640 AC                   when      lbaisl = ' CH'
640 AC                   eval      lblvl2 = 11

640 AC                   when      lbaisl = ' CI'
640 AC                   eval      lblvl2 = 12

640 AC                   when      lbaisl = ' CJ'
640 AC                   eval      lblvl2 = 13

500iDC**                 when      lwszon = 'CLR'
500iMC                   when      lwwhdp = 'CLR'
500dAC                   eval      lblvl2 = 99

500dA*      DRY

     C                   when      lbaisl < ' DZ'
     C                   eval      lblvl2 = 1

     C                   when      lbaisl = ' DZ'
     C                             and lbloc <= 591
     C                   eval      lblvl2 = 2

     C                   when      lbaisl >= ' RA' and lbaisl <= ' RF'
     C                   eval      lblvl2 = 3

     C                   when      lbaisl = ' DZ'
     C                             and lbloc >= 592
     C                   eval      lblvl2 = 4

     C                   other
     C                   eval      lblvl2 = 99

     C                   endsl

650 AC     endcheneyocalaendsr

650 A*----------------------------------------------------------------
650 A*  cheneyseqgwb   -  Special sequencing for Cheney Bros. GWB
650 A*----------------------------------------------------------------
650 A
650 AC     cheneyseqgwb  begsr
650 AC                   eval      iflag = *off
650 A
650 A*    Only update type 'O' labels.
650 A
650 AC                   if            lbtype <> 'O'
650 AC                             and lbtype <> 'M'
650 AC                   eval      iflag = *on
650 AC                   goto      endcheneygwb
650 AC                   endif
650 A
650 A*    Retrieve corresponding WORKLBL record.
650 A
730dDC**   lblbl#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lblbl#) worklblw;
730dM /end-free
650 AC                   if        not %found
650 AC                   eval      lwszon = *blanks
650 AC                   endif
650 A
650 A*    Update LBLVL2 field, which will set the picking order in LABEL32C
650 A
650 AC                   select
650 A
650 A*      Merge Labels
650 A
650 AC                   when      lbtype = 'M'
650 AC                   eval      lblvl2 = 50
650 A
650 A*      Produce
650 A
650 AC                   when      lwszon = 'PRD' and lwwhdp = 'DRY'
650 AC                   eval      lblvl2 = 1
650 A
650 AC                   when      lwszon = 'PRD' and lwwhdp = 'CLR'
650 AC                   eval      lblvl2 = 2
650 A
650 AC                   when      lwszon = 'PRD'
650 AC                   eval      lblvl2 = 99
650 A
650 A*      CLR
650 A
650 AC                   when      lbaisl = ' CE'
650aDC*                            and lbloc >= 97
650aDC*                            and lbloc <= 127
650 AC                   eval      lblvl2 = 1
650 A
650 AC                   when      lbaisl = ' CD'
650aDC*                            and lbloc >= 101
650aDC*                            and lbloc <= 135
650 AC                   eval      lblvl2 = 3
650 A
650 A*      FRZ
650 A
650 AC                   when      lbaisl = ' FF'
650aDC*                            and lbloc >= 602
650aDC*                            and lbloc <= 636
650 AC                   eval      lblvl2 = 6
650 A
650 AC                   when      lbaisl = ' FE'
650aDC*                            and lbloc >= 501
650aDC*                            and lbloc <= 520
650 AC                   eval      lblvl2 = 9
650 A
650 AC                   when      lbaisl = ' FD'
650aDC*                            and lbloc >= 401
650aDC*                            and lbloc <= 420
650 AC                   eval      lblvl2 = 12
650 A
650 AC                   when      lbaisl = ' FC'
650aDC*                            and lbloc >= 301
650aDC*                            and lbloc <= 320
650 AC                   eval      lblvl2 = 15
650 A
650 AC                   when      lbaisl = ' FB'
650aDC*                            and lbloc >= 201
650aDC*                            and lbloc <= 220
650 AC                   eval      lblvl2 = 18
650 A
650 AC                   when      lbaisl = ' FA'
650aDC*                            and lbloc >= 101
650aDC*                            and lbloc <= 120
650 AC                   eval      lblvl2 = 21
650 A
650 AC                   when      lbaisl = ' FG'
650aDC*                            and lbloc >= 101
650aDC*                            and lbloc <= 149
650 AC                   eval      lblvl2 = 24
650 A
650 A*      CLR
650 A
650 AC                   when      lbaisl = ' CC'
650aDC*                            and lbloc >= 101
650aDC*                            and lbloc <= 156
650 AC                   eval      lblvl2 = 27
650 A
650 AC                   when      lbaisl = ' CB'
650aDC*                            and lbloc >= 102
650aDC*                            and lbloc <= 130
650 AC                   eval      lblvl2 = 30
650 A
650 AC                   when      lbaisl = ' CA'
650aDC*                            and lbloc >= 97
650aDC*                            and lbloc <= 133
650 AC                   eval      lblvl2 = 33
650 A
650 AC                   when      lbaisl = ' GB'
650aDC*                            and lbloc >= 101
650aDC*                            and lbloc <= 201
650 AC                   eval      lblvl2 = 36
650 A
650 AC                   when      lbaisl = ' CM'
650aDC*                            and lbloc >= 100
650aDC*                            and lbloc <= 100
650 AC                   eval      lblvl2 = 39
650 A
650 A*      DRY
650 A
650 AC                   other
650 AC                   eval      lblvl2 = 50
650 A
650 AC                   endsl
650 A
650 AC     endcheneygwb  endsr
CBI A
CBI A*----------------------------------------------------------------
CBI A*  cheneyseqpnt   -  Special sequencing for Cheney Bros. PuntaGorda
CBI A*----------------------------------------------------------------
CBI A
CBI AC     cheneyseqpnt  begsr
CBI AC                   eval      iflag = *off
CBI A
CBI A*    Only update type 'O' labels.
CBI A
CBI AC                   if            lbtype <> 'O'
CBI AC                             and lbtype <> 'M'
CBI AC                   eval      iflag = *on
CBI AC                   goto      endcheneypnt
CBI AC                   endif
CBI A
CBI A*    Retrieve corresponding SLOT2 record.
CBI A
CBIdDC*                  if           lbaisl = ' DX'
CBIdDC*                            or lbaisl = ' DY'
CBIdMC                   if           lbaisl = ' FX'
CBIaAC                             or lbaisl = ' FY'
CBI AC     keysl2        chain     slot2
CBI AC                   if        not %found
CBI AC                   eval      slside = 0
CBI AC                   endif
CBI AC                   endif
CBIcA
CBIcA*    Retrieve corresponding WORKLBL record.
CBIcA
CBIcAC                   if           lbaisl = ' FX'
CBIcAC                             or lbaisl = ' FY'
730dDC**   lblbl#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lblbl#) worklblw;
730dM /end-free
CBIcAC                   if        not %found
CBIcAC                   eval      lwszon = *blanks
CBIcAC                   endif
CBIcAC                   endif
CBI A
CBI A*    Update LBLVL2 field, which will set the picking order in LABEL32C
CBI A
CBI AC                   select
CBI A
CBI A*      Dept DRY
CBI A
CBIiAC                   when          lbwhdp = 'DRY'
CBIiAC                             and lbaisl >= ' DA'
CBIiAC                             and lbaisl <= ' DP'
CBIiAC                   eval      lblvl2 = 1
CBI A
CBIiAC                   when          lbwhdp = 'DRY'
CBIiAC                             and lbaisl >= ' CL'
CBIiAC                             and lbaisl <= ' CN'
CBIiAC                   eval      lblvl2 = 5

CBIdDC*                  when          lbwhdp = 'DRY'
CBIdDC*                            and lbaisl = ' DX'
CBIdDC*                            and slside  = 0
CBIdDC*                  eval      lblvl2 = 1
CBI A
CBIdDC*                  when          lbwhdp = 'DRY'
CBIdDC*                            and lbaisl = ' DY'
CBIdDC*                            and slside  = 0
CBIdDC*                  eval      lblvl2 = 5
CBI A
CBIdDC*                  when          lbwhdp = 'DRY'
CBIdDC*                            and lbaisl = ' DX'
CBIdDC*                            and slside  = 1
CBIdDC*                  eval      lblvl2 = 10
CBI A
CBIdDC*                  when          lbwhdp = 'DRY'
CBIdDC*                            and lbaisl = ' DY'
CBIdDC*                            and slside  = 1
CBIdDC*                  eval      lblvl2 = 15
CBI A
CBIaA*------------------------------------------------------------
CBIaA*      Dept FRZ
CBIaA
CBIaAC                   when          lbwhdp = 'FRZ'
CBIaAC                             and lbaisl = ' FX'
CBIaAC                             and slside  = 1
CBIcAC                             and lwszon  <> 'ICE'
CBIaAC                   eval      lblvl2 = 20
CBIaA
CBIaAC                   when          lbwhdp = 'FRZ'
CBIaAC                             and lbaisl = ' FY'
CBIaAC                             and slside  = 1
CBIcAC                             and lwszon  <> 'ICE'
CBIaAC                   eval      lblvl2 = 25
CBIaA
CBIaAC                   when          lbwhdp = 'FRZ'
CBIaAC                             and lbaisl = ' FX'
CBIaAC                             and slside  = 0
CBIcAC                             and lwszon  <> 'ICE'
CBIaAC                   eval      lblvl2 = 30
CBIaA
CBIaAC                   when          lbwhdp = 'FRZ'
CBIaAC                             and lbaisl = ' FY'
CBIaAC                             and slside  = 0
CBIcAC                             and lwszon  <> 'ICE'
CBIaAC                   eval      lblvl2 = 35
CBI A
CBI AC                   other
CBI AC                   eval      lblvl2 = 50
CBI A
CBI AC                   endsl
CBI A
CBI AC     endcheneypnt  endsr
CBIeA
CBIeA*----------------------------------------------------------------
CBIeA*  cheneyseqpdgrn -  Special sequencing for Cheney Bros. Greensboro
CBIeA*----------------------------------------------------------------
CBIeA
CBIeAC     cheneyseqpdgrnbegsr
CBIeAC                   eval      iflag = *off
CBIeA
CBIeA*    Only update type 'O' labels.
CBIeA
CBIeAC                   if            lbtype <> 'O'
CBIeAC                             and lbtype <> 'M'
CBIeAC                   eval      iflag = *on
CBIeAC                   goto      endcheneypdgrn
CBIeAC                   endif
CBIeA
CBIeA*    Retrieve corresponding SLOT2 record.
CBIeA*      Commented out until needed.
CBIeA
CBIeMC**                 if           lbaisl = ' FX'
CBIeAC**                           or lbaisl = ' FY'
CBIeAC**   keysl2        chain     slot2
CBIeAC**                 if        not %found
CBIeAC**                 eval      slside = 0
CBIeAC**                 endif
CBIeAC**                 endif
CBIeA
CBIeA*    Retrieve corresponding WORKLBL record.
CBIeA*      Commented out until needed.
CBIeA
CBIeAC**                 if           lbaisl = ' FX'
CBIeAC**                           or lbaisl = ' FY'
CBIeAC**   lblbl#        chain     worklbl
CBIeAC**                 if        not %found
CBIeAC**                 eval      lwszon = *blanks
CBIeAC**                 endif
CBIeAC**                 endif
CBIeA
CBIeA*    Update LBLVL2 field, which will set the picking order in LABEL32C
CBIeA
CBIeAC                   select
CBIeA*------------------------------------------------------------
CBIeA*      Dept CLR
CBIeAC                   when          lbwhdp = 'CLR'
CBIeAC                   select
CBIlDC*                  when          lbaisl >= ' HA'
CBIlDC*                            and lbaisl <= ' HB'
CBIlDC*                  eval      lblvl2 = 1
CBIeA
CBIlDC*                  when          lbaisl >= ' JB'
CBIlDC*                            and lbaisl <= ' JD'
CBIlDC*                  eval      lblvl2 = 15
CBIeA
CBIlAC                   when          lbaisl = ' MT'
CBIlAC                   eval      lblvl2 = 60
CBIlA
CBIlAC                   when         lbaisl = ' SA'
CBIlAC                             or lbaisl = ' SB'
CBIlAC                   eval      lblvl2 = 62
CBIlA
CBIlAC                   when          lbaisl = ' FS'
CBIlAC                   eval      lblvl2 = 64
CBIlA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept DRY
CBIeAC                   when          lbwhdp = 'DRY'
CBIeAC                   select
CBIlDC*                  when          lbaisl >= ' GA'
CBIlDC*                            and lbaisl <= ' GC'
CBIlDC*                  eval      lblvl2 = 5
CBIeA
CBIlDC*                  when          lbaisl = ' CH'
CBIlDC*                  eval      lblvl2 = 10
CBIeA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept FRZ
CBIeA
CBIeAC                   when          lbwhdp = 'FRZ'
CBIeAC                   select
CBIeA
CBIlAC                   when          lbaisl = ' MT'
CBIlAC                   eval      lblvl2 = 70
CBIlA
CBIlAC                   when          lbaisl = ' FS'
CBIlAC                   eval      lblvl2 = 72
CBIlA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept <All Others>.
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeAC     endcheneypdgrnendsr
CBIeA
CBIeA*----------------------------------------------------------------
CBIeA*  cheneyseqpdgld -  Special sequencing for Cheney Bros. Goldsboro
CBIeA*----------------------------------------------------------------
CBIeA
CBIeAC     cheneyseqpdgldbegsr
CBIeAC                   eval      iflag = *off
CBIeA
CBIeA*    Only update type 'O' labels.
CBIeA
CBIeAC                   if            lbtype <> 'O'
CBIeAC                             and lbtype <> 'M'
CBIeAC                   eval      iflag = *on
CBIeAC                   goto      endcheneypdgld
CBIeAC                   endif
CBIeA
CBIeA*    Retrieve corresponding SLOT2 record.
CBIeA*      Commented out until needed.
CBIeA
CBIeMC                   if           lbaisl = ' CA'
CBIeMC                             or lbaisl = ' CC'
CBIeAC     keysl2        chain     slot2
CBIeAC                   if        not %found(slot2)
CBIeAC                   eval      slside = 0
CBIeAC                   endif
CBIeAC                   endif
CBIeA
CBIeA*    Retrieve corresponding WORKLBL record.
CBIeA*      Commented out until needed.
CBIeA
CBIeAC**                 if           lbaisl = ' FX'
CBIeAC**                           or lbaisl = ' FY'
CBIeAC**   lblbl#        chain     worklbl
CBIeAC**                 if        not %found
CBIeAC**                 eval      lwszon = *blanks
CBIeAC**                 endif
CBIeAC**                 endif
CBIeA
CBIeA*    Update LBLVL2 field, which will set the picking order in LABEL32C
CBIeA
CBIeAC                   select
CBIeA*------------------------------------------------------------
CBIeA*      Dept CLR
CBIeAC                   when          lbwhdp = 'CLR'

CBIeAC                   select
CBIeAC                   when          lbaisl = ' CC'
CBIeAC                                 and lbloc  = 002
CBIeAC                                 and lbrlvl = 1
CBIeAC                                 and lbhand = ' B'
CBIeAC                   eval      lblvl2 = 1

CBIeAC                   when          lbaisl = ' CC'
CBIeAC                                 and lbloc >= 003
CBIeAC                                 and lbloc <= 007
CBIeAC                                 and lbrlvl = 1
CBIeAC                                 and lbhand >= ' B'
CBIeAC                                 and lbhand <= ' C'
CBIeAC                                 and slside  = 1
CBIeAC                   eval      lblvl2 = 5

CBIeAC                   when          lbaisl = ' CA'
CBIeAC                                 and lbloc >= 057
CBIeAC                                 and lbloc <= 070
CBIeAC                   eval      lblvl2 = 10

CBIeAC                   when          lbaisl = ' CB'
CBIeAC                                 and lbloc >= 028
CBIeAC                                 and lbloc <= 042
CBIeA ***                              and slside = 1
CBIeAC                   eval      lblvl2 = 15

CBIeA ***                when          lbaisl = ' CB'
CBIeA ***                              and lbloc >= 028
CBIeA ***                              and lbloc <= 042
CBIeA ***                              and slside = 0
CBIeA ***                eval      lblvl2 = 20

CBIeAC                   when          lbaisl = ' CB'
CBIeAC                                 and lbloc = 092
CBIeAC                                 and lbrlvl = 2
CBIeAC                                 and lbhand = ' C'
CBIeAC                   eval      lblvl2 = 25

CBIeAC                   when          lbaisl = ' CB'
CBIeAC                                 and lbloc = 092
CBIeAC                                 and lbrlvl = 3
CBIeAC                                 and lbhand = ' C'
CBIeAC                   eval      lblvl2 = 25
CBIfA
CBIfAC                   when          lbaisl = ' CC'
CBIfAC                   eval      lblvl2 = 30
CBIeA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept DRY
CBIeAC                   when          lbwhdp = 'DRY'
CBIeAC                   select
CBIgA
CBIgAC                   when          lbaisl = ' DA'
CBIgAC                   eval      lblvl2 = 10
CBIeA
CBIeAC                   when          lbaisl = ' AB'
CBIeAC                   eval      lblvl2 = 15

CBIeAC                   when          lbaisl = ' AA'
CBIeAC                   eval      lblvl2 = 20

CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept FRZ
CBIeA
CBIeAC                   when          lbwhdp = 'FRZ'
CBIeAC                   select
CBIeA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept <All Others>.
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeAC     endcheneypdgldendsr
CBIeA
CBIeA*----------------------------------------------------------------
CBIeA*  cheneyseqpdsta -  Special sequencing for Cheney Bros. Statesville
CBIeA*----------------------------------------------------------------
CBIeA
CBIeAC     cheneyseqpdstabegsr
CBIeAC                   eval      iflag = *off
CBIeA
CBIeA*    Only update type 'O' labels.
CBIeA
CBIeAC                   if            lbtype <> 'O'
CBIeAC                             and lbtype <> 'M'
CBIeAC                   eval      iflag = *on
CBIeAC                   goto      endcheneypdsta
CBIeAC                   endif
CBIeA
CBIeA*    Retrieve corresponding SLOT2 record.
CBIeA*      Commented out until needed.
CBIeA
CBIeMC**                 if           lbaisl = ' FX'
CBIeAC**                           or lbaisl = ' FY'
CBIeAC**   keysl2        chain     slot2
CBIeAC**                 if        not %found
CBIeAC**                 eval      slside = 0
CBIeAC**                 endif
CBIeAC**                 endif
CBIeA
CBIeA*    Retrieve corresponding WORKLBL record.
CBIeA*      Commented out until needed.
CBIeA
CBIhAC                   if            lbaisl >= ' CA'
CBIhAC                             and lbaisl <= ' CD'
730dDC**   lblbl#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lblbl#) worklblw;
730dM /end-free
CBIhAC                   if        not %found
CBIhAC                   eval      lwszon = *blanks
CBIhAC                   endif
CBIhAC                   endif
CBIeA
CBIeA*    Update LBLVL2 field, which will set the picking order in LABEL32C
CBIeA
CBIeAC                   select
CBIeA*------------------------------------------------------------
CBIhM*      Dept CLR & not PRD pick zone.
CBIeAC                   when          lbwhdp = 'CLR'
CBIhAC                             and lwszon <> 'PRD'
CBIeAC                   select
CBIeAC                   when          lbaisl = ' TE'
CBIeAC                   eval      lblvl2 = 1
CBIeA
CBIeAC                   when          lbaisl >= ' TA'
CBIeAC                             and lbaisl <= ' TD'
CBIeAC                   eval      lblvl2 = 5
CBIeA
CBIeAC                   when          lbaisl >= ' TF'
CBIeAC                             and lbaisl <= ' TH'
CBIeAC                   eval      lblvl2 = 10
CBIhA
CBIhAC                   other
CBIhAC                   eval      lblvl2 = 50
CBIhA
CBIhAC                   endsl
CBIhA
CBIhA*------------------------------------------------------------
CBIhA*      Dept CLR & PRD pick zone.
CBIhAC                   when          lbwhdp = 'CLR'
CBIhAC                             and lwszon = 'PRD'
CBIhAC                   select
CBIhAC                   when          lbaisl = ' CA'
CBIhAC                                 and lbloc >= 098
CBIhAC                                 and lbloc <= 208
CBIhAC                   eval      lblvl2 = 1
CBIhA
CBIhAC                   when          lbaisl = ' CB'
CBIhAC                                 and lbloc >= 101
CBIhAC                                 and lbloc <= 136
CBIhAC                   eval      lblvl2 = 5
CBIhA
CBIhAC                   when          lbaisl = ' CC'
CBIhAC                                 and lbloc >= 169
CBIhAC                                 and lbloc <= 204
CBIhAC                   eval      lblvl2 = 10
CBIhA
CBIhAC                   when          lbaisl = ' CD'
CBIhAC                                 and lbloc >= 101
CBIhAC                                 and lbloc <= 140
CBIhAC                   eval      lblvl2 = 15
CBIhA
CBIhAC                   when          lbaisl = ' CB'
CBIhAC                                 and lbloc >= 149
CBIhAC                                 and lbloc <= 204
CBIhAC                   eval      lblvl2 = 20
CBIhA
CBIhAC                   when          lbaisl = ' CC'
CBIhAC                                 and lbloc >= 101
CBIhAC                                 and lbloc <= 156
CBIhAC                   eval      lblvl2 = 25
CBIhA
CBIhAC                   when          lbaisl = ' CD'
CBIhAC                                 and lbloc >= 146
CBIhAC                                 and lbloc <= 208
CBIhAC                   eval      lblvl2 = 30
CBIhA
CBIeA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept DRY
CBIeAC                   when          lbwhdp = 'DRY'
CBIeAC                   select
CBIeA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept FRZ
CBIeA
CBIeAC                   when          lbwhdp = 'FRZ'
CBIeAC                   select
CBIeA
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeA*------------------------------------------------------------
CBIeA*      Dept <All Others>.
CBIeAC                   other
CBIeAC                   eval      lblvl2 = 50
CBIeA
CBIeAC                   endsl
CBIeA
CBIeAC     endcheneypdstaendsr
CBIjA
CBIjA*----------------------------------------------------------------
CBIjA*  cheneyseqmlk -  Special sequencing for Cheney Bros. MLK
CBIjA*----------------------------------------------------------------
CBIjA
CBIjAC     cheneyseqmlk  begsr
CBIjAC                   eval      iflag = *off
CBIjA
CBIjA*    Only update type 'O' labels.
CBIjA
CBIjAC                   if            lbtype <> 'O'
CBIjAC                             and lbtype <> 'M'
CBIjAC                   eval      iflag = *on
CBIjAC                   goto      endcheneymlk
CBIjAC                   endif
CBIjA
CBIjA*    Retrieve corresponding SLOT2 record.
CBIjA*      Commented out until needed.
CBIjA
CBIjAC*                  if           lbwhdp = 'DRY'
CBIjAC*    keysl2        chain     slot2
CBIjAC*                  if        not %found
CBIjAC*                  eval      slside = 0
CBIjAC*                  endif
CBIjAC*                  endif
CBIjA
CBIjA*    Retrieve corresponding WORKLBL record.
CBIjA*      Commented out until needed.
CBIjA
CBIjAC*                  if            lbaisl >= ' CA'
CBIjAC*                            and lbaisl <= ' CD'
CBIjAC*    lblbl#        chain     worklbl
CBIjAC*                  if        not %found
CBIjAC*                  eval      lwszon = *blanks
CBIjAC*                  endif
CBIjAC*                  endif
CBIjA
CBIjA*    Update LBLVL2 field, which will set the picking order in LABEL32C
CBIjA
CBIjAC                   select
CBIjA*------------------------------------------------------------
CBIjA*      Dept CLR & not PRD pick zone.
CBIjAC                   when          lbwhdp = 'CLR'
CBIjAC                             and lwszon <> 'PRD'
CBIjAC
CBIjAC                   select
CBIjA
CBIjAC                   other
CBIjAC                   eval      lblvl2 = 50
CBIjA
CBIjAC                   endsl
CBIjA
CBIjA*------------------------------------------------------------
CBIjA*      Dept CLR & PRD pick zone.
CBIjAC                   when          lbwhdp = 'CLR'
CBIjAC                             and lwszon = 'PRD'
CBIjAC                   select
CBIjA
CBIjAC                   other
CBIjAC                   eval      lblvl2 = 50
CBIjA
CBIjAC                   endsl
CBIjA
CBIjA*------------------------------------------------------------
CBIjA*      Dept DRY
CBIjAC                   when          lbwhdp = 'DRY'
CBIjAC                   select
CBIkAC                   when          lbaisl = ' MB'
CBIkAC                   eval      lblvl2 = 1
CBIkA*
CBIkAC                   when          lbaisl = ' MC'
CBIkAC                   eval      lblvl2 = 2
CBIkA*
CBIkAC                   when          lbaisl = ' MD'
CBIkAC                   eval      lblvl2 = 3
CBIkA*
CBIkDC*                  when          lbaisl = ' MA'
CBIkDC*                            and lbloc  >= 121
CBIkDC*                            and slside  = 1
CBIjA*
CBIkDC*                            or  lbaisl =  ' MA'
CBIkDC*                            and lbloc  >= 146
CBIkDC*                            and slside  = 0
CBIkAC                   when          lbaisl = ' MA'
CBIkDC*                  eval      lblvl2 = 1
CBIkMC                   eval      lblvl2 = 4
CBIjA
CBIkDC*                  when          lbaisl > ' MA'
CBIkDC*                  eval      lblvl2 = 10
CBIjA
CBIkDC*                  when          lbaisl = ' MA'
CBIkDC*                            and lbloc  < 121
CBIkDC*                            and slside = 1
CBIjA*
CBIkDC*                            or  lbaisl =  ' MA'
CBIkDC*                            and lbloc  < 146
CBIkDC*                            and slside = 0
CBIkDC*                  eval      lblvl2 = 20
CBIjA
CBIjAC                   other
CBIjAC                   eval      lblvl2 = 50
CBIjA
CBIjAC                   endsl
CBIjA
CBIjA*------------------------------------------------------------
CBIjA*      Dept FRZ
CBIjA
CBIjAC                   when          lbwhdp = 'FRZ'
CBIjAC                   select
CBIjA
CBIjAC                   other
CBIjAC                   eval      lblvl2 = 50
CBIjA
CBIjAC                   endsl
CBIjA
CBIjA*------------------------------------------------------------
CBIjA*      Dept <All Others>.
CBIjAC                   other
CBIjAC                   eval      lblvl2 = 50
CBIjA
CBIjAC                   endsl
CBIjA
CBIjAC     endcheneymlk  endsr

DRYgA*----------------------------------------------------------------
DRYgA*  dryseqbronx -  Special sequencing for Dairyland - Bronx whse
DRYgA*----------------------------------------------------------------
DRYgA
DRYgAC     dryseqbronx   begsr
     C                   eval      iflag = *off

DRYgA*    Only update type 'O' labels.

DRYgAC                   if        lbtype <> 'O'
DRYgAC                   eval      iflag = *on
DRYgAC                   goto      enddrybronx
DRYgAC                   endif

DRYgA*    Set up custom sequence for use with LABEL32D.

     C                   select
DRYgA*------------------------------------------
     C                   when      lbwhdp = 'DRY'

     C                   select
     C                   when          lbaisl >= '01A'
     C                             and lbaisl <= '01A'
DRYiMC                   eval      lblvl2 = 03

     C                   when          lbaisl >= '02A'
     C                             and lbaisl <= '02A'
DRYiMC                   eval      lblvl2 = 05

     C                   when          lbaisl >= '03A'
     C                             and lbaisl <= '03A'
DRYiMC                   eval      lblvl2 = 07

     C                   when          lbaisl >= '04A'
     C                             and lbaisl <= '04A'
DRYiMC                   eval      lblvl2 = 09

     C                   when          lbaisl >= '05A'
     C                             and lbaisl <= '05A'
DRYiMC                   eval      lblvl2 = 11

     C                   when          lbaisl >= '06A'
     C                             and lbaisl <= '06A'
DRYiMC                   eval      lblvl2 = 13

DRYhMC                   when          lbaisl >= '17A'
DRYhMC                             and lbaisl <= '17A'
DRYiMC                   eval      lblvl2 = 15

DRYhMC                   when          lbaisl >= '18A'
DRYhMC                             and lbaisl <= '18A'
DRYiMC                   eval      lblvl2 = 17

DRYhMC                   when          lbaisl >= '19A'
DRYhMC                             and lbaisl <= '19A'
DRYiMC                   eval      lblvl2 = 19

DRYhMC                   when          lbaisl >= '20A'
DRYhMC                             and lbaisl <= '20A'
DRYiMC                   eval      lblvl2 = 21

DRYhAC                   when          lbaisl >= '21A'
DRYhAC                             and lbaisl <= '21A'
DRYiAC                   eval      lblvl2 = 23

DRYhAC                   when          lbaisl >= '22A'
DRYhAC                             and lbaisl <= '22A'
DRYiAC                   eval      lblvl2 = 25

DRYhAC                   when          lbaisl >= '23A'
DRYhAC                             and lbaisl <= '23A'
DRYiAC                   eval      lblvl2 = 27

DRYhAC                   when          lbaisl >= '049'
DRYhAC                             and lbaisl <= '049'
DRYiAC                   eval      lblvl2 = 29

DRYhMC                   when          lbaisl >= '07A'
DRYhMC                             and lbaisl <= '07A'
DRYiMC                   eval      lblvl2 = 31

     C                   when          lbaisl >= '100'
     C                             and lbaisl <= '100'
DRYiMC                   eval      lblvl2 = 33

     C                   when          lbaisl >= '102'
     C                             and lbaisl <= '104'
DRYiMC                   eval      lblvl2 = 35

     C                   when          lbaisl >= '106'
     C                             and lbaisl <= '106'
DRYiMC                   eval      lblvl2 = 37

     C                   when          lbaisl >= '108'
     C                             and lbaisl <= '112'
DRYiMC                   eval      lblvl2 = 39

     C                   when          lbaisl >= '114'
     C                             and lbaisl <= '116'
DRYiMC                   eval      lblvl2 = 41

     C                   when          lbaisl >= '118'
     C                             and lbaisl <= '118'
DRYiMC                   eval      lblvl2 = 43

     C                   when          lbaisl >= '120'
     C                             and lbaisl <= '120'
DRYiMC                   eval      lblvl2 = 45

     C                   when          lbaisl >= '150'
     C                             and lbaisl <= '151'
DRYiMC                   eval      lblvl2 = 47

     C                   when          lbaisl >= '200'
     C                             and lbaisl <= '202'
DRYiMC                   eval      lblvl2 = 49

     C                   when          lbaisl >= '204'
     C                             and lbaisl <= '204'
DRYiMC                   eval      lblvl2 = 51

     C                   when          lbaisl >= '206'
     C                             and lbaisl <= '206'
DRYiMC                   eval      lblvl2 = 53

DRYhDC*                  when          lbaisl >= '300'
DRYhDC*                            and lbaisl <= '300'
DRYhDC*                  eval      lblvl2 = 47

     C                   when          lbaisl >= '007'
     C                             and lbaisl <= '007'
DRYiMC                   eval      lblvl2 = 57

     C                   other
     C                   eval      lblvl2 = 70

     C                   endsl

DRYgA*------------------------------------------
     C                   when      lbwhdp = 'FRZ'

     C                   select
     C                   when          lbaisl >= '012'
     C                             and lbaisl <= '015'
     C                   eval      lblvl2 = 57

     C                   other
     C                   eval      lblvl2 = 70

     C                   endsl

DRYgA*------------------------------------------
     C                   when      lbwhdp = 'REF'

     C                   select
DRYiMC                   when          lbaisl >= '016'
DRYiMC                             and lbaisl <= '016'
DRYiMC                   eval      lblvl2 = 01

     C                   when          lbaisl >= '008'
     C                             and lbaisl <= '011'
DRYiMC                   eval      lblvl2 = 55

DRYhDC*                  when          lbaisl >= '116'
DRYhDC*                            and lbaisl <= '116'
DRYhDC*                  eval      lblvl2 = 53

DRYhDC*                  when          lbaisl >= '120'
DRYhDC*                            and lbaisl <= '120'
DRYhDC*                  eval      lblvl2 = 55

     C                   other
     C                   eval      lblvl2 = 70

     C                   endsl

DRYgA*------------------------------------------

     *      Then everything else.

     *        Note, by setting everything else to 70, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 70, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 70

DRYgAC                   endsl
DRYgA
DRYgAC     enddrybronx   endsr

DRYeA*----------------------------------------------------------------
DRYeA*  dryseqla -  Special sequencing for Dairyland - Los Angeles
DRYeA*----------------------------------------------------------------
DRYeA
DRYeAC     dryseqla      begsr
     C                   eval      iflag = *off

     *    Only update type 'O' labels.

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      enddryla
     C                   endif


     *    Only update DRY and REF labels.

     C                   if        lbwhdp <> 'DRY'
     C                             and lbwhdp <> 'REF'
     C                   eval      iflag = *on
     C                   goto      enddryla
     C                   endif

     *    Set up custom sequence for use with LABEL32D.

     C                   select

     *      Pick aisle A first.

     C                   when      %subst(lbaisl:1:1) = 'A'
     *
     C                   eval      lblvl2 = 10

     *      Pick aisle B next.

     C                   when      %subst(lbaisl:1:1) = 'B'
     *
     C                   eval      lblvl2 = 15

     *      Pick aisle W next.

     C                   when      %subst(lbaisl:1:1) = 'W'
     *
     C                   eval      lblvl2 = 20

     *      Pick aisle C next.

     C                   when      %subst(lbaisl:1:1) = 'C'
     *
     C                   eval      lblvl2 = 25

     *      Pick aisle M next.

     C                   when      %subst(lbaisl:1:1) = 'M'
     *
     C                   eval      lblvl2 = 30

     *      Pick aisle D next.

     C                   when      %subst(lbaisl:1:1) = 'D'
     *
     C                   eval      lblvl2 = 35

     *      Pick aisle N next.

     C                   when      %subst(lbaisl:1:1) = 'N'
     *
     C                   eval      lblvl2 = 40

     *      Pick aisle R next.

     C                   when      %subst(lbaisl:1:1) = 'R'
     *
     C                   eval      lblvl2 = 45

     *      Pick aisle J next.

     C                   when      %subst(lbaisl:1:1) = 'J'
     *
     C                   eval      lblvl2 = 50

     *      Then everything else.

     *        Note, by setting everything else to 60, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 60

     C                   endsl

     C     enddryla      endsr

DRYjA*----------------------------------------------------------------
DRYjA*  dryseqsanfran -  Special sequencing for Dairyland - SF,CA whse
DRYjA*----------------------------------------------------------------
DRYjA
DRYjAC     dryseqsanfran begsr
DRYjAC                   eval      iflag = *off

DRYjA*    Only update type 'O' labels.

DRYjAC                   if        lbtype <> 'O'
DRYjAC                   eval      iflag = *on
DRYjAC                   goto      enddrysf
DRYjAC                   endif

DRYjA*    Set up custom sequence for use with LABEL32D.

DRYjAC                   select
DRYjA*------------------------------------------
DRYjAC                   when      lbwhdp = 'DRY'
DRYjAC                   eval      lblvl2 = 01

DRYjA*------------------------------------------
DRYjAC                   when      lbwhdp = 'REF'
DRYjAC                   eval      lblvl2 = 02

DRYjA*------------------------------------------

     *      Then everything else.

     *        Note, by setting everything else to 70, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 70, the
     *        possibility is left open to assign an aisle to be picked last

DRYjAC                   other
DRYjAC                   eval      lblvl2 = 70

DRYjAC                   endsl
DRYjA
DRYjAC     enddrysf      endsr

DRYkA*----------------------------------------------------------------
DRYkA*  dryseqqznchi -  Special sequencing for Dairyland - Qzina Chicago
DRYkA*----------------------------------------------------------------
DRYkA
DRYkAC     dryseqqznchi  begsr
DRYkAC                   eval      iflag = *off

DRYkA*    Only update type 'O' labels.

DRYkAC                   if        lbtype <> 'O'
DRYkAC                   eval      iflag = *on
DRYkAC                   goto      enddrychi
DRYkAC                   endif

DRYkA*    Set up custom sequence for use with LABEL32D.

DRYkAC                   select
DRYkA*------------------------------------------
DRYkAC                   when      lbwhdp = 'DRY'
DRYkAC                   select
DRYkAC                   when          lbaisl >= '192'
DRYkAC                             and lbaisl <= '197'
DRYkAC                   eval      lblvl2 = 1
DRYkA*
DRYkAC                   when          lbaisl >= '301'
DRYkAC                             and lbaisl <= '301'
DRYkAC                   eval      lblvl2 = 7
DRYkA*
DRYkAC                   other
DRYkAC                   eval      lblvl2 = 70
DRYkAC                   endsl

DRYkA*------------------------------------------
DRYkAC                   when      lbwhdp = 'REF'
DRYkAC                   select
DRYkAC                   when          lbaisl >= '600'
DRYkAC                             and lbaisl <= '605'
DRYkAC                   eval      lblvl2 = 3
DRYkA*
DRYkAC                   other
DRYkAC                   eval      lblvl2 = 70
DRYkAC                   endsl

DRYkA*------------------------------------------
DRYkAC                   when      lbwhdp = 'CHC'
DRYkAC                   select
DRYkAC                   when          lbaisl >= '300'
DRYkAC                             and lbaisl <= '301'
DRYkAC                   eval      lblvl2 = 5
DRYkA*
DRYkAC                   when          lbaisl >= '302'
DRYkAC                             and lbaisl <= '307'
DRYkAC                   eval      lblvl2 = 9
DRYkA*
DRYkAC                   other
DRYkAC                   eval      lblvl2 = 70
DRYkAC                   endsl

DRYkA*------------------------------------------

     *      Then everything else.

     *        Note, by setting everything else to 70, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 70, the
     *        possibility is left open to assign an aisle to be picked last

DRYkAC                   other
DRYkAC                   eval      lblvl2 = 70

DRYkAC                   endsl
DRYkA
DRYkAC     enddrychi     endsr
DRYmA
DRYmA*----------------------------------------------------------------
DRYmA*  dryseqtoronto -  Special sequencing for Dairyland - Qzina Toronto
DRYmA*----------------------------------------------------------------
DRYmA
DRYmAC     dryseqtoronto begsr
DRYmAC                   eval      iflag = *off

DRYmA*    Only update type 'O' labels.

DRYmAC                   if        lbtype <> 'O'
DRYmAC                   eval      iflag = *on
DRYmAC                   goto      enddrytor
DRYmAC                   endif

DRYmA*    Set up custom sequence for use with LABEL32D.

DRYmAC                   select
DRYmA*------------------------------------------
DRYmAC                   when      lbwhdp = 'DRY'
DRYmAC                   select
DRYmAC**                 when          lbaisl >= '192'
DRYmAC**                           and lbaisl <= '197'
DRYmAC**                 eval      lblvl2 = 1
DRYmA*
DRYmAC                   other
DRYmAC                   eval      lblvl2 = 10
DRYmAC                   endsl

DRYmA*------------------------------------------
DRYmAC                   when      lbwhdp = 'CHC'
DRYmAC                   select
DRYmAC**                 when          lbaisl >= '300'
DRYmAC**                           and lbaisl <= '301'
DRYmAC**                 eval      lblvl2 = 5
DRYmA*
DRYmAC                   other
DRYmAC                   eval      lblvl2 = 20
DRYmAC                   endsl

DRYmA*------------------------------------------
DRYmAC                   when      lbwhdp = 'REF'
DRYmAC                   select
DRYmAC**                 when          lbaisl >= '600'
DRYmAC**                           and lbaisl <= '605'
DRYmAC**                 eval      lblvl2 = 3
DRYmA*
DRYmAC                   other
DRYmAC                   eval      lblvl2 = 30
DRYmAC                   endsl

DRYmA*------------------------------------------

     *      Then everything else.

     *        Note, by setting everything else to 70, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 70, the
     *        possibility is left open to assign an aisle to be picked last

DRYmAC                   other
DRYmAC                   eval      lblvl2 = 70

DRYmAC                   endsl
DRYmA
DRYmAC     enddrytor     endsr

CTW A*----------------------------------------------------------------
CTW A*  citywhoseq  -  Special sequencing for City Wholesale
CTW A*----------------------------------------------------------------
CTW A
CTW AC     citywhoseq    begsr
CTW AC                   eval      iflag = *off
CTW A
CTW A*    Only update department DRY labels.
CTW A
CTW AC                   if        lbwhdp <> 'DRY'
CTW AC                   eval      iflag = *on
CTW AC                   goto      endcitywho
CTW AC                   endif
CTW A
CTW A*    Set up custom sequence for use with LABEL32C.
CTW A
CTW AC                   select
CTW A
CTW A*      Pick DRY, aisles before 032 or aisle 032 up to loc 449.
CTW A
CTW AC                   when      lbaisl < '032'
CTW AC                             or   lbaisl = '032'
CTW AC                             and  lbloc <= 449
CTW AC                   eval      lblvl2 = 1
CTW A
CTW A
CTW A*      Pick DRY, aisles 132,151 after aisle 032, loc 449.
CTW A
CTW AC                   when      lbwhdp = 'DRY'
CTW AC                             and (lbaisl = '132'
CTW AC                             or   lbaisl = '151')
CTW AC                   eval      lblvl2 = 20
CTW A
CTW A*      Then everything else.
CTW A
CTW A*        Note, by setting everything else to 50, the normal Aisle,
CTW A*        Picking Seq. order takes affect. Also, by using 50, the
CTW A*        possibility is left open to assign an aisle to be picked last
CTW A
CTW AC                   other
CTW AC                   eval      lblvl2 = 50
CTW A
CTW AC                   endsl
CTW A
CTW AC     endcitywho    endsr

DRY A*----------------------------------------------------------------
DRY A*  dairylandseq  -  Special sequencing for Dairyland - Hanover
DRY A*----------------------------------------------------------------
DRY A
DRY AC     dairylandseq  begsr
     C                   eval      iflag = *off

     *    Only update type 'O' labels.

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      enddairyland
     C                   endif

     *    Set up custom sequence for use with LABEL32D.

     C                   select

     *      Pick aisle A first.
DRYbA*      or aisles 020 - 027

     C                   when          lbwhdp = 'DRY'
DRYaTC*                            and %subst(lbaisl:1:1) = 'A'
DRYbA*
DRYbAC                                 and (%subst(lbaisl:1:1) = 'A'
DRYbA*
DRYcAC*                                 or  slaisl >= '020'
DRYcAC*                                and  slaisl <= '027')
DRYcMC                                  or  lbaisl >= '020'
DRYcMC                                 and  lbaisl <= '027')
DRYbMC                   eval      lblvl2 = 10

DRYbM*      Pick aisles 060 - 064 next.

DRYbMC                   when          lbwhdp = 'REF'
DRYaTC*                            and %subst(lbaisl:1:1) = 'R'
DRYbA*
DRYcDC*                                and slaisl >= '060'
DRYcDC*                                and slaisl <= '064'
DRYcMC                                 and lbaisl >= '060'
DRYcMC                                 and lbaisl <= '064'
DRYbMC                   eval      lblvl2 = 15

DRYbM*      Pick aisles 080 - 085 next.

DRYbMC                   when          lbwhdp = 'REF'
DRYaTC*                            and %subst(lbaisl:1:1) = 'T'
DRYbA*
DRYcDC*                  when              slaisl >= '080'
DRYcDC*                                and slaisl <= '085'
DRYcMC*                  when              lbaisl >= '080'
DRYdMC                                 and lbaisl >= '080'
DRYcMC                                 and lbaisl <= '085'
DRYbMC                   eval      lblvl2 = 20

DRYbM*      Pick aisles 100 - 101 next.

DRYbMC                   when          lbwhdp = 'REF'
DRYaTC*                            and %subst(lbaisl:1:1) = 'W'
DRYbA*
DRYcDC*                  when              slaisl >= '100'
DRYcDC*                                and slaisl <= '101'
DRYcMC*                  when              lbaisl >= '100'
DRYdMC                                 and lbaisl >= '100'
DRYcMC                                 and lbaisl <= '101'
DRYbMC                   eval      lblvl2 = 25

DRYbM*      Pick aisle 110 next.

DRYbMC                   when          lbwhdp = 'DRY'
DRYaTC*                            and %subst(lbaisl:1:1) = 'Y'
DRYbA*
DRYcDC*                  when              slaisl >= '110'
DRYcDC*                                and slaisl <= '110'
DRYcMC*                  when              lbaisl >= '110'
DRYDMC                                 and lbaisl >= '110'
DRYcMC                                 and lbaisl <= '110'
DRYbMC                   eval      lblvl2 = 30

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

DRY AC     enddairyland  endsr

DRYfA*----------------------------------------------------------------
DRYfA *  DRYSEQCINC    -  Special sequencing for Dairyland - Cincinnati
DRYfA*----------------------------------------------------------------
DRYfA
DRYfAC     dryseqcinc    begsr
     C                   eval      iflag = *off

      *    Only update type 'O' labels.

     C                   if        lbgrp2 <> 'W'
     C                   eval      iflag = *on
     C                   goto      enddrycin
     C                   endif

      *    Set up custom sequence for use with LABEL32D.
     C                   select

      *      Pick department DRY and REF together

     C                   when          lbwhdp = 'DRY' or
     C                                 lbwhdp = 'REF'
     C                   eval      lblvl2 = 10

      *      Then everything else.

      *        Note, by setting everything else to 50, the normal Aisle
      *        Picking Seq. order takes affect. Also, by using 50, the
      *        possibility is left open to assign an aisle to be picked

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     enddrycin     endsr

640aA*----------------------------------------------------------------
640aA*  dierksseq  -  Special sequencing for Dierks Waukesha
640aA*----------------------------------------------------------------
640aA
640aAC     dierksseq     begsr
     C                   eval      iflag = *off

     *    Retrieve corresponding WORKLBL record for Merge records.
     *    Note, for Merge records we need to get the corresponding label
     *    record from WORKLBL because we do not populate the aisle field
     *    for merge records.

     C                   eval      lwaisl = *blanks
     C                   if        lbtype = 'M'
730dDC**   lbctr#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lbctr#) worklblw;
730dM /end-free
     C                   if        not %found
     C                   eval      lwaisl = *blanks
     C                   endif
     C                   endif

     *    Working with all departments.

     *    Only update type 'O' and 'M' labels.

     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'M'
     C                   eval      iflag = *on
     C                   goto      enddierks
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Type 'O' and Aisles <= D32

     C                   when      lbtype = 'O'
     C                             and lbaisl <= 'D32'
     C                   eval      lblvl2 = 10

     *      Type 'M' and Zone is DRYPIR or DRYCC

     C                   when      lbtype = 'M'
     C                             and (lwszon = 'DRYPIR'
     C                                  or lwszon = 'DRYCC')
     C                   eval      lblvl2 = 15

     *      Type 'O' and Aisles > D32 and <= R71

     C                   when      lbtype = 'O'
     C                             and lbaisl >  'D32'
     C                             and lbaisl <= 'R71'
     C                   eval      lblvl2 = 20

     *      Type 'M' and Zone is REFPIR

     C                   when      lbtype = 'M'
     C                             and lwszon = 'REFPIR'
     C                   eval      lblvl2 = 25

     *      Then everything else.

     *        Note, by setting everything else to 80, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 80, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 80

     C                   endsl

     C     enddierks     endsr

510dA*----------------------------------------------------------------
510dA*  ellenbeeseq  -  Special sequencing for Ellenbee-Leggett
510dA*----------------------------------------------------------------
510dA
510dAC     ellenbeeseq   begsr
     C                   eval      iflag = *off

     *    Retrieve corresponding SLOT2 record for aisle 2F.

     C                   if        lbaisl = ' 2F'
     C     keysl2        chain     slot2
     C                   if        not %found
     C                   eval      slside = 0
     C                   endif
     C                   endif

     *    Retrieve corresponding WORKLBL record for Merge records.
     *    Note, for Merge records we need to get the corresponding label
     *    record from WORKLBL because we do not populate the aisle field
     *    for merge records.

     C                   eval      lwaisl = *blanks
     C                   if        lbtype = 'M'
730dDC**   lbctr#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lbctr#) worklblw;
730dM /end-free
     C                   if        not %found
     C                   eval      lwaisl = *blanks
     C                   endif
     C                   endif

     *    Working with all departments.

     *    Only update type 'O' and 'M' labels.

     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'M'
     C                   eval      iflag = *on
     C                   goto      endellenbee
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Aisles 3G - 3M with unit weight >= 35 lbs (DRY PIR)

     C                   when      lwaisl >= ' 3G'
     C                             and lwaisl <= ' 3M'
510iDC**                           and lwuwgt >= 35
510iMC                             and lwuwgt >= ophvy
     C                   eval      lblvl2 = 5

     *      Aisles 3A - 3D (DRY Main Floor)

     C                   when      lbaisl >= ' 3A'
     C                             and lbaisl <= ' 3D'
     C                   eval      lblvl2 = 10

     *      Aisle 2X (DRY Main Floor)

     C                   when      lbaisl = ' 2X'
     C                   eval      lblvl2 = 15

     *      Aisles 2A - 2D with unit weight >= 35 lbs (COOL PIR)

     C                   when      lwaisl >= ' 2A'
     C                             and lwaisl <= ' 2D'
510iDC**                           and lwuwgt >= 35
510iMC                             and lwuwgt >= ophvy
     C                   eval      lblvl2 = 20

     *      Aisles 2F Even (COOL Main Floor)

     C                   when      lbaisl >= ' 2F'
     C                             and slside = 0
     C                   eval      lblvl2 = 25

     *      Aisles 2G - 2K (COOL Main Floor)
530bD*      Aisles 2G - 2L (COOL Main Floor)
530bM*      Aisles 2G - 2H or 2Z (COOL Main Floor)

     C                   when      lbaisl >= ' 2G'
530bDC*                            and lbaisl <= ' 2L'
530bMC                             and lbaisl <= ' 2H'
530bAC                             or  lbaisl  = ' 2Z'
     C                   eval      lblvl2 = 25
530bA
530bA*      Aisles 2I - 2L (COOL Main Floor)
530bAC                   when      lbaisl >= ' 2I'
530bAC                             and lbaisl <= ' 2L'
530bAC                   eval      lblvl2 = 27

     *      Aisles 2A - 2D with unit weight < 35 lbs (COOL PIR)

     C                   when      lwaisl >= ' 2A'
     C                             and lwaisl <= ' 2D'
510iDC**                           and lwuwgt < 35
510iMC                             and lwuwgt < ophvy
     C                   eval      lblvl2 = 30

     *      Aisles 3E - 3F (DRY Main Floor)

     C                   when      lbaisl >= ' 3E'
     C                             and lbaisl <= ' 3F'
     C                   eval      lblvl2 = 35

     *      Aisles 3G - 3M with unit weight < 35 lbs (DRY PIR)

     C                   when      lwaisl >= ' 3G'
     C                             and lwaisl <= ' 3M'
510iDC**                           and lwuwgt < 35
510iMC                             and lwuwgt < ophvy
     C                   eval      lblvl2 = 40

     *      Aisle 2F Odd (Box Beef)

     C                   when      lbaisl = ' 2F'
     C                             and slside = 1
     C                   eval      lblvl2 = 45

     *      Aisles 1A - 1D with unit weight >= 35 lbs (FRZ PIR)

     C                   when      lwaisl >= ' 1A'
     C                             and lwaisl <= ' 1D'
510iDC**                           and lwuwgt >= 35
510iMC                             and lwuwgt >= ophvy
     C                   eval      lblvl2 = 50

     *      Aisles 1M - 1T (FRZ Main Floor)

     C                   when      lbaisl >= ' 1M'
     C                             and lbaisl <= ' 1T'
     C                   eval      lblvl2 = 55

     *      Aisles 1A - 1D with unit weight < 35 lbs (FRZ PIR)

     C                   when      lwaisl >= ' 1A'
     C                             and lwaisl <= ' 1D'
510iDC**                           and lwuwgt < 35
510iMC                             and lwuwgt < ophvy
530bMC                   eval      lblvl2 = 65

530bD*      Aisles 2Z (FRZ Main Floor)

530bDC*                  when      lbaisl = ' 2Z'
530bDC*                  eval      lblvl2 = 60

     *      Then everything else.

     *        Note, by setting everything else to 80, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 80, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 80

     C                   endsl

     C     endellenbee   endsr

500fA*----------------------------------------------------------------
500fA*  eiseq  -  Special sequencing for European Imports
500fA*----------------------------------------------------------------
500fA
500fAC     eiseq         begsr
     C                   eval      iflag = *off

     *    Only update department DRY type 'O' labels.
EIc  *    Change to process FRZ, CANDY, DRY, REF dept order.

EIc  C*                  if        lbwhdp <> 'DRY'
EIc AC*                            and lbwhdp <> 'REF'
EIc  C*                            or lbtype <> 'O'
EIc MC                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endei
     C                   endif

     *    Set up custom sequence for use with LABEL32C.
EIc  *    Process in requested dept order for new warehouse.
EIc AC                   select
EIc  *    Pick dept FRZ first.
EIc AC                   when      lbwhdp = 'FRZ'
EIe DC*                  eval      lblvl2 = 5
EIe MC                   eval      lblvl2 = 40
EIc  *    ... then CANDY.
EIc AC                   when      lbwhdp = 'CANDY'
EIe DC*                  eval      lblvl2 = 10
EIe MC                   eval      lblvl2 = 5
EIc  *    ... then DRY  .
EIc AC                   when      lbwhdp = 'DRY'
EId AC                   select
EId AC                   when         lbaisl = ' 11'
EId AC                             or lbaisl = 'N11'
EIc  C                   eval      lblvl2 = 15
EId A*
EId AC                   when          lbaisl >= '  7'
EId AC                             and lbaisl <= ' 10'
EId AC                             or  lbaisl >= 'N07'
EId AC                             and lbaisl <= 'N10'
EId AC                   eval      lblvl2 = 17
EId A*
EId AC                   when          lbaisl >= ' 12'
EId AC                             and lbaisl <= ' 19'
EId AC                             or  lbaisl >= 'N12'
EId AC                             and lbaisl <= 'N19'
EId AC                   eval      lblvl2 = 19
EId A*
EId AC                   other
EId AC                   eval      lblvl2 = 30
EId A*
EId AC                   endsl
EId A*
EIc  *    ... then REF  .
EIc AC                   when      lbwhdp = 'REF'
EId DC*                  eval      lblvl2 = 20
EIe DC*                  eval      lblvl2 = 40
EIe MC                   eval      lblvl2 = 35
     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last
EIc AC                   other
EIc AC                   eval      lblvl2 = 50
EIc A
EIc AC                   endsl
EIa A
EIc A**************************************************************
EIc  ***  Code below has been replaced for new warehouse.
EIa A*      Process aisles in department DRY.
EIc AC*                  select
EIc AC*                  when      lbwhdp = 'DRY  '
EIc D *
EIc DC*                  select
EIc D *
EIc D*      Pick aisles 11 - 14 first.
EIc D *
EIc DC*                  when      lbaisl < ' 15'
EIc DC*                  eval      lblvl2 = 1
EIc D *
EIc D*      Then aisles 16 - 18.
EIc D *
EIc DC*                  when      lbaisl >= ' 16' and lbaisl <= ' 18'
EIc DC*                  eval      lblvl2 = 2
EIc D *
EIc A*      Then aisle 61 - 62.
EIc A *
EIc AC*                  when      lbaisl >= ' 61' and lbaisl <= ' 62'
EIc AC*                  eval      lblvl2 = 3
EIc D *
520aA*      Then aisle 70 - 77.  (For Holiday Season).
520aA *
520aAC*                  when      lbaisl >= ' 70' and lbaisl <= ' 77'
520aAC*                  eval      lblvl2 = 5
EIc D *
EIb A*      Then aisle 80 - 82.  (For Holiday Season).
EIb A *
EIb AC*                  when      lbaisl >= ' 80' and lbaisl <= ' 82'
EIb AC*                  eval      lblvl2 = 6
EIc D *
EIc D*      Then aisle 15.
EIc D *
EIc DC*                  when      lbaisl = ' 15'
EIc DC*                  eval      lblvl2 = 3
520eDC*                  eval      lblvl2 = 4
520eMC*                  eval      lblvl2 = 7
EIc D *
EIc D*      Then everything else.
EIc D *
EIc D*        Note, by setting everything else to 50, the normal Aisle,
EIc D*        Picking Seq. order takes affect. Also, by using 50, the
EIc D*        possibility is left open to assign an aisle to be picked last
EIc D *
EIc DC*                  other
EIc DC*                  eval      lblvl2 = 50
EIc D *
EIc DC*                  endsl
EIa A *
EIa A*------------------------------------------------------------------
EIa A *
EIa A*      Process aisles in department REF.
EIa AC*                  when      lbwhdp = 'REF  '
EIa A *
EIa AC*                  select
EIa A*      Pick aisles 46 - 48 first.
EIa A *
EIa AC*                  when      lbaisl >= ' 46' and lbaisl <= ' 48'
EIa AC*                  eval      lblvl2 = 1
EIa A *
EIa A*      Then everything else.
EIa A *
EIa A*        Note, by setting everything else to 50, the normal Aisle,
EIa A*        Picking Seq. order takes affect. Also, by using 50, the
EIa A*        possibility is left open to assign an aisle to be picked last
EIa A *
EIa AC*                  other
EIa AC*                  eval      lblvl2 = 50
EIa A *
EIa AC*                  endsl
EIa A *
EIa AC*                  endsl
EIc A**************************************************************

     C     endei         endsr

530cA*----------------------------------------------------------------
530cA*  fshseq - Special sequencing for Fischer
530cA*----------------------------------------------------------------
530cA
530cAC     fshseq        begsr
     C                   eval      iflag = *off

     *    Only update department DRY type 'O' labels.

     C                   if        lbwhdp <> 'DRY' and
     C                             lbwhdp <> 'REF'
FFCfAC                             and lbwhdp <> 'FRZ'
     C                             or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endfsh
     C                   endif

     *      Process aisles in department DRY.
     C                   select
     C                   when      lbwhdp = 'DRY  '

     C                   select

     *      Force these slots to be last.
      *    changed to do selection on item  9/13/10
     C*                  when      lbdisp = '10-110-1    ' or
     C*                            lbdisp = '11-104-2    ' or
     C*                            lbdisp = '11-105-2    ' or
     C*                            lbdisp = '11-110-2    ' or
     C*                            lbdisp = '11-116-2    ' or
     C*                            lbdisp = '11-117-2    ' or
     C*                            lbdisp = '11-124-2    ' or
     C*                            lbdisp = '11-131-2    ' or
     C*                            lbdisp = '11-135-2    ' or
     C*                            lbdisp = '11-138-2    ' or
     C*                            lbdisp = '11-141-2    ' or
     C*                            lbdisp = '11-148-2    ' or
     C*                            lbdisp = '11-150-2    ' or
     C*                            lbdisp = '11-159-1    ' or
     C*                            lbdisp = '11-167-1    ' or
     C*                            lbdisp = '13-101-1    ' or
     C*                            lbdisp = '13-103-1    ' or
     C*                            lbdisp = '13-105-1    ' or
     C*                            lbdisp = '13-114-1    ' or
     C*                            lbdisp = '13-115-1    ' or
     C*                            lbdisp = '13-116-1    ' or
     C*                            lbdisp = '13-117-1    ' or
     C*                            lbdisp = '13-118-1    ' or
     C*                            lbdisp = '13-119-1    ' or
     C*                            lbdisp = '13-120-1    ' or
     C*                            lbdisp = '13-121-1    ' or
     C*                            lbdisp = '13-124-1    '
     C                   when      lbitem = '7726'     or
FSHbDC*                            lbitem = '7730'     or
FSHbDC*                            lbitem = '7742'     or
     C                             lbitem = '19900'    or
     C                             lbitem = '19901'    or
     C                             lbitem = '19902'    or
     C                             lbitem = '19903'    or
     C                             lbitem = '19904'    or
     C                             lbitem = '19905'    or
     C                             lbitem = '19906'    or
     C                             lbitem = '19907'    or
     C                             lbitem = '19908'    or
     C                             lbitem = '19910'    or
     C                             lbitem = '19912'    or
     C                             lbitem = '19913'    or
     C                             lbitem = '19914'    or
     C                             lbitem = '19915'    or
     C                             lbitem = '19916'    or
     C                             lbitem = '19917'    or
     C                             lbitem = '19918'    or
     C                             lbitem = '19919'    or
     C                             lbitem = '19921'    or
     C                             lbitem = '19922'    or
     C                             lbitem = '19923'    or
     C                             lbitem = '19924'    or
     C                             lbitem = '19930'    or
     C                             lbitem = '19931'    or
     C                             lbitem = '19934'    or
     C                             lbitem = '19945'    or
     C                             lbitem = '19956'    or
     C                             lbitem = '19985'    or
FSHbDC*                            lbitem = '20000'    or
FSHbDC*                            lbitem = '20005'    or
FSHbAC                             lbitem = '19986'    or
FSHbAC                             lbitem = '19911'    or
FSHbAC                             lbitem = '19955'    or
FSHbAC                             lbitem = '19960'    or
FSHbAC                             lbitem = '19975'    or
FSHbAC                             lbitem = '19980'    or
FSHbAC                             lbitem = '20010'    or
FSHbAC                             lbitem = '20015'    or
FSHbAC                             lbitem = '20055'    or
FSHbAC                             lbitem = '20065'    or
FSHbAC                             lbitem = '20070'    or
FSHbAC                             lbitem = '90110'    or
FSHbAC                             lbitem = '90115'    or
FSHbAC                             lbitem = '42500'    or
FSHbAC                             lbitem = 'BP202'    or
FSHbAC                             lbitem = '21405'    or
FSHbAC                             lbitem = '21420'    or
FSHbAC                             lbitem = 'SP352'    or
FSHbAC                             lbitem = 'SP361'    or
FSHbAC                             lbitem = '19989'    or
FSHbAC                             lbitem = '19990'    or
FSHbAC                             lbitem = '19991'    or
FSHbAC                             lbitem = '19992'    or
FSHbAC                             lbitem = '19993'    or
FSHbAC                             lbitem = '19994'    or
FSHbAC                             lbitem = '19961'    or
FSHbAC                             lbitem = '19962'    or
FSHbAC                             lbitem = '19963'    or
FSHcAC                             lbitem = '19925'    or
FSHcAC                             lbitem = '19926'    or
FSHcAC                             lbitem = '19927'    or
FSHcAC                             lbitem = '19928'    or
FSHcAC                             lbitem = '19933'    or
FSHcAC                             lbitem = '19947'    or
FSHcAC                             lbitem = '19964'    or
FSHcAC                             lbitem = '19966'    or
FSHcAC                             lbitem = '19967'    or
FSHcAC                             lbitem = '19968'    or
FSHcAC                             lbitem = '19969'    or
FSHcAC                             lbitem = '19970'    or
FSHdAC                             lbitem = '19946'    or
FSHdAC                             lbitem = '19948'    or
FSHdAC                             lbitem = '19949'    or
FSHdAC                             lbitem = '19951'    or
     C                             lbitem = '85015'    or
     C                             lbitem = 'BP201'    or
     C                             lbitem = 'BP212'    or
     C                             lbitem = 'CE315'
     C                   eval      lblvl2 = 60

     *      Then everything else.

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl
     C                   when      lbwhdp = 'REF  '
FFCeAC                   select
FSHaA*      Force these slots to be last.
FSHaAC*                  when      lbdisp = '41-101-2    ' or
FSHaAC*                            lbdisp = '41-102-2    ' or
FSHaAC*                            lbdisp = '41-103-2    ' or
FSHaAC*                            lbdisp = '41-110-2    ' or
FSHaAC*                            lbdisp = '41-111-2    ' or
FSHaAC*                            lbdisp = '42-102-2    ' or
FSHaAC*                            lbdisp = '42-103-2    ' or
FSHaAC*                            lbdisp = '43-102-2    ' or
FSHaAC*                            lbdisp = '43-111-2    ' or
FSHaAC*                            lbdisp = '43-112-2    ' or
FSHaAC*                            lbdisp = '44-110-2    ' or
FSHaAC*                            lbdisp = '44-112-2    '
FFCeA*
FFCeAC                   when          lbaisl >= ' 40'
FFCeAC                             and lbaisl <= ' 43'
FFCeAC                             and (lbdisp <> '40-101-1')
FSHaAC*                  eval      lblvl2 = 61
FFCeAC                   eval      lblvl2 = 50
FFCeA*
FFCeAC                   when          lbaisl = ' 44'
FFCeAC                             and lbloc  <= 104
FFCeAC                   eval      lblvl2 = 54
FFCeA*
FFCeAC                   when          lbdisp = '40-101-1'
FFCeAC                   eval      lblvl2 = 55
FFCeA*
FFCeAC                   when          lbaisl = ' 44'
FFCeAC                             and lbloc  > 104
FFCeAC                              or lbaisl > ' 44'
FFCeAC                   eval      lblvl2 = 60
FSHaA*
     C*                  when      lbitem = '32026'
     C*                  eval      lblvl2 = 60
     C*                  other
     C                   eval      lblvl2 = 50
FFCeMC                   endsl
FFCfA*
FFCfAC                   when      lbwhdp = 'FRZ  '
FFCfAC                   select
FFCfAC                   when          lbaisl = ' 76'
FFCfAC                   eval      lblvl2 = 5
FFCfA*
FFCfAC                   when          lbaisl >= ' 70'
FFCfAC                             and lbaisl <= ' 73'
FFCfAC                   eval      lblvl2 = 10
FFCfA*
FFCfAC                   other
FFCfAC                   eval      lblvl2 = 50
FFCfAC                   endsl

     C                   endsl

     C     endfsh        endsr
FRF A
FRF A*----------------------------------------------------------------
FRF A*  frfseq  -  Special sequencing for Fox River Foods
FRF A*----------------------------------------------------------------
FRF A
FRF AC     frfseq        begsr
FRF AC                   eval      iflag = *off
FRF A
FRF A
FRF A*    Set up custom sequence for use with LABEL32C.
FRF A
FRF AC                   select
FRF A
FRF A*      Pick dept DRY aisles 1st
FRF A
FRF AC                   when      lbwhdp = 'DRY'
FRFaA*
FRFaAC                   select
FRFaAC                   when          lbaisl >= ' AA'
FRFaAC                             and lbaisl <= ' BB'
FRF AC                   eval      lblvl2 = 1
FRFaA*
FRFaAC                   when          lbaisl = ' JJ'
FRFaAC                   eval      lblvl2 = 2
FRFaA*
FRFaAC                   when          lbaisl = ' DR'
FRFaAC                   eval      lblvl2 = 3
FRFaA*
FRFaAC                   when          lbaisl = ' NW'
FRFaAC                   eval      lblvl2 = 4
FRFaA*
FRFaAC                   when          lbaisl = ' 32'
FRFaAC                   eval      lblvl2 = 5
FRFaA*
FRFaAC                   when          lbaisl = ' 30'
FRFaAC                             and lbloc >= 100
FRFaAC                             and lbloc <= 117
FRFaAC                   eval      lblvl2 = 6
FRFaA*
FRFaAC                   when          lbaisl >= ' 33'
FRFaAC                             and lbaisl <= ' 34'
FRFaAC                   eval      lblvl2 = 7
FRFaA*
FRFaAC                   when          lbaisl = ' 30'
FRFaAC                             and lbloc >= 119
FRFaAC                             and lbloc <= 137
FRFaAC                   eval      lblvl2 = 8
FRFaA*
FRFaAC                   when          lbaisl >= ' 35'
FRFaAC                             and lbaisl <= ' 36'
FRFaAC                   eval      lblvl2 = 9
FRFaA*
FRFaAC                   when          lbaisl = ' 30'
FRFaAC                             and lbloc >= 139
FRFaAC                             and lbloc <= 157
FRFaAC                   eval      lblvl2 = 10
FRFaA*
FRFaAC                   when          lbaisl >= ' 37'
FRFaAC                             and lbaisl <= ' 38'
FRFaAC                   eval      lblvl2 = 11
FRFaA*
FRFaAC                   when          lbaisl = ' 30'
FRFaAC                             and lbloc >= 159
FRFaAC                             and lbloc <= 177
FRFaAC                   eval      lblvl2 = 12
FRFaA*
FRFaAC                   when          lbaisl >= ' 39'
FRFaAC                             and lbaisl <= ' 40'
FRFaAC                   eval      lblvl2 = 13
FRFaA*
FRFaAC                   when          lbaisl = ' 30'
FRFaAC                             and lbloc >= 179
FRFaAC                   eval      lblvl2 = 14
FRFaA*
FRFaAC                   when          lbaisl >= ' 41'
FRFaAC                             and lbaisl <= ' 42'
FRFaAC                   eval      lblvl2 = 15
FRFaA*
FRFaAC                   when          lbaisl = ' 31'
FRFaAC                             and lbloc >= 101
FRFaAC                             and lbloc <= 115
FRFaAC                   eval      lblvl2 = 16
FRFaA*
FRFaAC                   when          lbaisl >= ' 43'
FRFaAC                             and lbaisl <= ' 44'
FRFaAC                   eval      lblvl2 = 17
FRFaA*
FRFaAC                   when          lbaisl = ' 31'
FRFaAC                             and lbloc >= 117
FRFaAC                             and lbloc <= 137
FRFaAC                   eval      lblvl2 = 18
FRFaA*
FRFaAC                   when          lbaisl >= ' 45'
FRFaAC                             and lbaisl <= ' 46'
FRFaAC                   eval      lblvl2 = 19
FRFaA*
FRFaAC                   when          lbaisl = ' 31'
FRFaAC                             and lbloc >= 139
FRFaAC                             and lbloc <= 153
FRFaAC                   eval      lblvl2 = 20
FRFaA*
FRFaAC                   when          lbaisl >= ' 47'
FRFaAC                             and lbaisl <= ' 48'
FRFaAC                   eval      lblvl2 = 21
FRFaA*
FRFaAC                   when          lbaisl = ' 31'
FRFaAC                             and lbloc >= 155
FRFaAC                             and lbloc <= 173
FRFaAC                   eval      lblvl2 = 22
FRFaA*
FRFaAC                   when          lbaisl >= ' 49'
FRFaAC                             and lbaisl <= ' 50'
FRFaAC                   eval      lblvl2 = 23
FRFaA*
FRFaAC                   when          lbaisl = ' 31'
FRFaAC                             and lbloc >= 175
FRFaAC                   eval      lblvl2 = 24
FRFaA*
FRFaAC                   when          lbaisl >= ' 51'
FRFaAC                             and lbaisl <= ' 52'
FRFaAC                   eval      lblvl2 = 25
FRFaA*
FRFaAC                   when          lbaisl = ' 81'
FRFaAC                             and lbloc >= 101
FRFaAC                             and lbloc <= 111
FRFaAC                   eval      lblvl2 = 26
FRFaA*
FRFaAC                   when          lbaisl >= ' 53'
FRFaAC                             and lbaisl <= ' 54'
FRFaAC                   eval      lblvl2 = 27
FRFaA*
FRFaAC                   when          lbaisl = ' 81'
FRFaAC                             and lbloc >= 113
FRFaAC                   eval      lblvl2 = 28
FRFaA*
FRFaAC                   when          lbaisl = ' 56'
FRFaAC                   eval      lblvl2 = 29
FRFaA*
FRFaAC                   when          lbaisl = ' 55'
FRFaAC                   eval      lblvl2 = 30
FRFaA*
FRFaAC                   when          lbaisl = ' 0F'
FRFaAC                   eval      lblvl2 = 31
FRFaA*
FRFaAC                   when          lbaisl = ' GN'
FRFaAC                   eval      lblvl2 = 32
FRFaA*
FRFaAC                   other
FRFaAC                   eval      lblvl2 = 33
FRFaA*
FRFaAC                   endsl
FRF A
FRF A*      Pick dept CLR aisles 2nd
FRF A
FRF AC                   when      lbwhdp = 'CLR'
FRFaA*
FRFaAC                   select
FRFaA*
FRFaAC                   when          lbaisl = ' 94'
FRFaA*      Slots 94GRN/94OBR.
FRFaAC                             and (lbloc = 186
FRFaAC                              or  lbloc = 189)
FRFaAC                   eval      lblvl2 = 34
FRFaA*
FRFaAC                   when          lbaisl  = ' ZZ'
FRFaAC                   eval      lblvl2 = 35
FRFaA*
FRFaAC                   when          lbaisl  = ' GG'
FRFaAC                   eval      lblvl2 = 36
FRFaA*
FRFaAC                   when          lbaisl  = ' 98'
FRFaAC                             and lbloc >= 720
FRFaAC                             and lbloc <= 720
FRFaAC                   eval      lblvl2 = 37
FRFaA*
FRFaAC                   when          lbaisl  = ' 98'
FRFaAC                             and lbloc >= 100
FRFaAC                             and lbloc <= 100
FRFaAC                             and lbrlvl = 1
FRFaAC                   eval      lblvl2 = 38
FRFaA*
FRFaAC                   when          lbaisl  = ' MT'
FRFaAC                   eval      lblvl2 = 39
FRFaA*
FRFaAC                   when          lbaisl  = ' 98'
FRFaAC                             and lbloc >= 100
FRFaAC                             and lbloc <= 146
FRFaAC                             and lbrlvl >= 2
FRFaAC                   eval      lblvl2 = 40
FRFaA*
FRFaAC                   when          lbaisl  = ' 96'
FRFaAC                   eval      lblvl2 = 41
FRFaA*
FRFaAC                   when          lbaisl  = ' 87'
FRFaAC                   eval      lblvl2 = 42
FRFaA*
FRFaAC                   when          lbaisl  = ' 98'
FRFaAC                             and lbloc >= 147
FRFaAC                             and lbloc <= 199
FRFaAC                   eval      lblvl2 = 43
FRFaA*
FRFaAC                   when          lbaisl  = ' 99'
FRFaAC                   eval      lblvl2 = 44
FRFaA*
FRFaAC                   when          lbaisl >= ' 88'
FRFaAC                             and lbaisl <= ' 95'
FRFaAC                   eval      lblvl2 = 45
FRFaA*
FRFaAC                   other
FRFaDC*                  eval      lblvl2 = 2
FRFaMC                   eval      lblvl2 = 46
FRFaA*
FRFaAC                   endsl
FRFaA
FRFaA*      Pick dept FRZ aisles 3rd
FRFaA
FRFaAC                   when      lbwhdp = 'FRZ'
FRFaA*
FRFaAC                   select
FRFaAC                   when          lbaisl  = ' 01'
FRFaAC                             and lbloc >= 801
FRFaAC                             and lbloc <= 801
FRFaAC                   eval      lblvl2 = 50
FRFaA*
FRFaAC                   when          lbaisl  = ' 08'
FRFaAC                   eval      lblvl2 = 51
FRFaA*
FRFaAC                   when          lbaisl  = ' 01'
FRFaAC                             and (lbloc >= 100
FRFaAC                             and  lbloc <= 179)
FRFaAC                             or  lbaisl >= ' 02'
FRFaAC                             and lbaisl <= ' 07'
FRFaAC                   eval      lblvl2 = 52
FRFaA*
FRFaAC                   when          lbaisl >= ' 09'
FRFaAC                             and lbaisl <= ' 10'
FRFaAC                   eval      lblvl2 = 53
FRFaA*
FRFaAC                   when          lbaisl  = ' 14'
FRFaAC                   eval      lblvl2 = 54
FRFaA*
FRFaAC                   when          lbaisl  = ' 18'
FRFaAC                   eval      lblvl2 = 55
FRFaA*
FRFaAC                   when          lbaisl >= ' 15'
FRFaAC                             and lbaisl <= ' 17'
FRFaAC                   eval      lblvl2 = 56
FRFaA*
FRFaAC                   when          lbaisl >= ' 19'
FRFaAC                             and lbaisl <= ' 24'
FRFaAC                   eval      lblvl2 = 57
FRFaA*
FRFaAC                   when          lbaisl  = ' 11'
FRFaAC                   eval      lblvl2 = 58
FRFaA*
FRFaAC                   when          lbaisl >= ' 25'
FRFaAC                             and lbaisl <= ' 29'
FRFaAC                   eval      lblvl2 = 59
FRFaA*
FRFaAC                   other
FRFaAC                   eval      lblvl2 = 60
FRFaA*
FRFaAC                   endsl
FRF A
FRF A*      Then everything else.
FRF A
FRF A*        Note, by setting everything else to 80, the normal Aisle,
FRF A*        Picking Seq. order takes affect. Also, by using 80, the
FRF A*        possibility is left open to assign an aisle to be picked last
FRF A
FRF AC                   other
FRF AC                   eval      lblvl2 = 80
FRF A
FRF AC                   endsl
FRF A
FRF AC     endfrf        endsr

510cA*----------------------------------------------------------------
510cA*  gscseq     -  Special sequencing for BiRite
510cA*----------------------------------------------------------------
510cA
510cAC     gscseq        begsr
     C                   eval      iflag = *off

     *    Only update Dept 7 (repack) type 'O' labels.

     C                   if        lbwhdp <> '7    '
     C                             or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endgsc
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle TD and following first.

     C                   when      lbaisl >= ' TD'
     C                   eval      lblvl2 = 1

     *      Pick aisle TA - TC second.

     C                   when      lbaisl >= ' TA'
     C                             and lbaisl <= ' TC'
     C                   eval      lblvl2 = 2

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endgsc        endsr

530aA*----------------------------------------------------------------
530aA*  halseyseq  -  Special sequencing for Halsey
530aA*----------------------------------------------------------------
530aA
530aAC     halseyseq     begsr
     C                   eval      iflag = *off

     **   Only update department REF
HALc **   Or FRZ
HALd **   Or DRY

     C                   if        lbwhdp <> 'REF'
HALc C                              and lbwhdp <> 'FRZ'
HALd C                              and lbwhdp <> 'DRY'
     C                   eval      iflag = *on
     C                   goto      endhalsey
     C                   endif

     **   Only update "O" type labels

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endhalsey
     C                   endif


     C                   select
     *      Pick aisles PA - PE last.

     C                   when      lbaisl >= ' PA' and lbaisl <= ' PE'
HALbDC***                eval      lblvl2 = 50
HALbMC                   eval      lblvl2 = 51
HALbA*      Pick aisles CA - CK first.
HALbA
HALbAC                   when      lbaisl >= ' CA' and lbaisl <= ' CK'
HALbAC                   eval      lblvl2 = 1
HALbA*      Pick aisles MA - MB first.
HALbA
HALbAC                   when      lbaisl >= ' MA' and lbaisl <= ' MB'
HALbAC                   eval      lblvl2 = 2
HALbA*      Pick aisles RE309 - RE315 next.
HALbA
HALbAC                   when      lbaisl = ' RE'
HALbAC                             and lbloc >= 309 and lbloc <= 315
HALbAC                   eval      lblvl2 = 3
HALcA*      Pick aisle FI first.
HALcA
HALcAC                   when      lbaisl >= ' FI' and lbaisl <= ' FM'
HALcAC                   eval      lblvl2 = 4
HALeA*      Pick aisle FA last in FRZ.
HALeA
HALeAC                   when      lbaisl = ' FA'
HALeAC                   eval      lblvl2 = 5
HALeA
HALdA*      Pick slots DK-000 thru DK-004 first for aisle DK
HALdA
HALdAC                   when      lbwhdp = 'DRY' and
HALdAC                             lbaisl <= ' DJ'
HALdAC                   eval      lblvl2 = 10
HALdA
HALdAC                   when      lbwhdp = 'DRY' and
HALdAC                             lbaisl = ' DK' and lbloc = 0
HALdAC                             and  lbrlvl < 4
HALdAC                   eval      lblvl2 = 20
HALcA
HALbA**     Then everything else.
HALbA**       Note, by setting everything else to 50, the normal Aisle,
HALbA**       Picking Seq. order takes affect. Also, by using 50, the  last
HALbA**       possibility is left open to assign an aisle to be picked last
HALbA**          Aisle PA and PE are set to 51 to insure they are last last
HALbAC                   other
HALbAC                   eval      lblvl2 = 50

     C                   endsl

     C     endhalsey     endsr

500eA*----------------------------------------------------------------
500eA*  harborseq  -  Special sequencing for I-Supply
500eA*----------------------------------------------------------------
500eA
500eAC     harborseq     begsr
     C                   eval      iflag = *off

520bD**   Only update department G and E type 'O' labels.
520bD **
520bDC**                 if        (lbwhdp <> 'E'
520bDC**                            and lbwhdp <> 'G')
520bDC**                           or lbtype <> 'O'
520bDC**                 eval      iflag = *on
520bDC**                 goto      endharbor
520bDC**                 endif
520bD **
520bD**   Set up custom sequence for use with LABEL32C.
520bD **
520bDC**                 select
520bD **
520bD**     Pick G first.
520bD **
520bDC**                 when      lbwhdp = 'G'
520bDC**                 eval      lblvl2 = 1
520bD **
520bD**     Then everything else.
520bD **
520bD**       Note, by setting everything else to 50, the normal Aisle,
520bD **       Picking Seq. order takes affect. Also, by using 50, the
520bD**       possibility is left open to assign an aisle to be picked last
520bD **
520bDC**                 other
520bDC**                 eval      lblvl2 = 50
520bD **
520bDC**                 endsl

     C     endharbor     endsr

HMWaA*----------------------------------------------------------------
HMWaA*  hmwagnerseq  -  Special sequencing for H&M Wagner
HMWaA*----------------------------------------------------------------
HMWaA
HMWaAC     hmwagnerseq   begsr
     C                   eval      iflag = *off

     *    Only update type 'O' labels.

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endhmwagner
     C                   endif

     *    Set up custom sequence for use with LABEL32D.

     C                   select

     *      Pick aisle ZXC first.

     C                   when      lbaisl = 'ZXC'
     C                   eval      lblvl2 = 10
HMWbA
HMWbA*      Pick slot CF-113-1 last.
HMWbA
HMWbAC                   when      lbaisl = 'CF '
HMWbAC                             and lbloc = 113
HMWbAC                             and lbrlvl = 1
HMWbAC                   eval      lblvl2 = 55

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

HMWaAC     endhmwagner   endsr


640bA*----------------------------------------------------------------
640bA*  icbseq  -  Special sequencing for Intercounty Bakers
640bA*----------------------------------------------------------------
640bA
640bAC     icbseq        begsr
     C                   eval      iflag = *off

     **   Only update department REF

     C*                  if        lbwhdp <> '1    '
     C*                  eval      iflag = *on
     C*                  goto      endicb
     C*                  endif

     **   Only update "O" type labels

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endicb
     C                   endif


     C                   select
     C                   when      lbwhdp = '1    '

     C                   select
     *      Pick slot is blank

     C                   when      lbaisl = '   '
     C                   eval      lblvl2 = 5

ICBcDC                   when      lbdisp = '40-102-1    '
ICBcDC                   eval      lblvl2 = 5
ICBcDC
ICBdA*      Pick aisle 40
ICBdA
ICBdAC                   when      lbaisl = ' 40'
ICBeDC*                  eval      lblvl2 = 54
ICBeAC                   eval      lblvl2 = 52
ICBdAC
ICBeA*      Pick aisle 30 Next
ICBeA
ICBeAC                   when      lbaisl = ' 30'
ICBeAC                   eval      lblvl2 = 54
ICBdAC
ICBbM*      Pick aisle 31 Last
ICBbM
ICBbMC                   when      lbaisl = ' 31'
ICBbMC                   eval      lblvl2 = 55
ICBbMC
ICBdA*      Pick aisle 31 Last.
ICBdA
ICBdAC                   when      lbaisl = ' OF'
ICBdAC                   eval      lblvl2 = 56
ICBdAC
     *      Pick slot 40-102-1 first.
     *      Pick slot C0915 first.

ICBbDC*                  when      lbdisp = 'C0915       '
ICBbDC*                  eval      lblvl2 = 5
ICBbDC*
ICBbD*      Pick aisle A next
ICBbDC*
ICBbDC*                  when      lbaisl = '  A'
ICBbDC*                  eval      lblvl2 = 10
ICBbDC*
ICBbD*      Pick aisle B next
ICBbDC*
ICBbDC*                  when      lbaisl = '  B'
ICBbDC*                  eval      lblvl2 = 15
ICBbDC*
ICBbD*      Pick aisle C, location < 101
ICBbDC*
ICBbDC*                  when      lbaisl = '  C'
ICBbDC*                            and lbloc < 101
ICBbDC*                  eval      lblvl2 = 20
ICBbDC*
ICBbD*      Pick aisle C, location > 101, location < 125
ICBbDC*
ICBbDC*                  when      lbaisl = '  C'
ICBbDC*                            and lbloc > 101
ICBbDC*                            and lbloc < 125
ICBbDC*                  eval      lblvl2 = 30
ICBbDC*
ICBbD*      Pick aisle C, location > 125
ICBbDC*
ICBbDC*                  when      lbaisl = '  C'
ICBbDC*                            and lbloc > 125
ICBbDC*                  eval      lblvl2 = 40
ICBbDC*
ICBbD*      Pick aisle C, location = 101
ICBbDC*
ICBbDC*                  when      lbaisl = '  C'
ICBbDC*                            and lbloc = 101
ICBbDC*                  eval      lblvl2 = 25
ICBbDC*
ICBbD*      Pick aisle C, location = 125
ICBbDC*
ICBbDC*                  when      lbaisl = '  C'
ICBbDC*                            and lbloc = 125
ICBbDC*                  eval      lblvl2 = 35

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     *      When department 2 and aisle C

     C                   when      lbwhdp = '2    '
ICBbDC*                            and lbaisl = '  C'
ICBbDC*
ICBbDC*                  select
ICBbDC*
ICBbD*      Pick aisle C, location = 101  C1031
ICBbDC*
ICBbDC*                  when      lbloc = 101
ICBbDC*                  eval      lblvl2 = 25
ICBbDC*
ICBbD*      Pick aisle C, location = 125  C1215
ICBbDC*
ICBbDC*                  when      lbloc = 125
ICBbDC*                  eval      lblvl2 = 35
ICBbDC*
ICBbDC*                  other
ICBbDC*                  eval      lblvl2 = 50
ICBbDC*
ICBbDC*                  endsl

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endicb        endsr

500cA*----------------------------------------------------------------
500cA*  isupplyseq  -  Special sequencing for I-Supply
500cA*----------------------------------------------------------------
500cA
500cAC     isupplyseq    begsr
     C                   eval      iflag = *off

510eM*    Only update DRY and FRZ departments.

500dMC                   if        (lbwhdp <> 'DRY'
510aDC**                            and lbwhdp <> 'FRZ')
510aMC                              and lbwhdp <> 'FROZ')
510eDC**                           or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endisupply
     C                   endif
510eA
510eA*    Only update type 'O' and 'M' labels.
510eA
510eAC                   if        lbtype <> 'O'
510eAC                             and lbtype <> 'M'
510eAC                   eval      iflag = *on
510eAC                   goto      endisupply
510eAC                   endif

     *    Grab first 2 characters of item number.

     C                   eval      temp2a = %subst(lbitem:1:2)

     *    Set up custom sequence for use with LABEL32C.

     C                   select

ISPa *      Pick DRY aisle G

ISPa C                   when      lbwhdp = 'DRY'
ISPa C                             and lbaisl = '  G'
ISPa C                             and lbloc >= 101 and lbloc <= 116
ISPa C                             and lbrlvl = 1 and lbhand = ' A'
     C                   eval      lblvl2 = 1

500dM*      Pick DRY item 13*, aisle A first.

500dAC                   when      lbwhdp = 'DRY'
500dMC                             and temp2a = '13' and lbaisl = '  A'
     C                   eval      lblvl2 = 1

500dM*      Pick DRY item 13*, aisle E second.

500dAC                   when      lbwhdp = 'DRY'
500dMC                             and temp2a = '13' and lbaisl = '  E'
     C                   eval      lblvl2 = 2

500dA*      Pick FRZ items 28*, 080025, 080099, 080101.

510aDC**                 when      lbwhdp = 'FRZ'
510aMC                   when      lbwhdp = 'FROZ'
500dMC                             and temp2a = '28'
510aDC**                           or (lbitem='080025'
510aDC**                                or lbitem='080099'
510aDC**                                or lbitem='080101')
     C                   eval      lblvl2 = 3

     *      Then everything else.

     *        Note, by setting everything else to 50, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 50, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C     endisupply    endsr

520gA*----------------------------------------------------------------
520gA*  jorseq  -  Special sequencing for Jordanos
520gA*----------------------------------------------------------------
520gA
520gAC     jorseq        begsr
520g C                   eval      iflag = *off

     *    Only update DRY type 'O' labels.

     C                   if        lbwhdp <> 'DRY'
     C                             or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endjor
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle before 'H' first

     C                   when      lbaisl < '  H'
     C                   eval      lblvl2 = 1

     *      Existing H, I, J, K aisles loc up to 190, pick 2nd

     C                   when      lbaisl = '  H'
     C                             and lbloc <= 190
     C                   eval      lblvl2 = 2

     C                   when      lbaisl = '  I'
     C                             and lbloc <= 190
     C                   eval      lblvl2 = 2

     C                   when      lbaisl = '  J'
     C                             and lbloc <= 190
     C                   eval      lblvl2 = 2

     C                   when      lbaisl = '  K'
     C                             and lbloc <= 190
     C                   eval      lblvl2 = 2

     *      New H, I, J, K aisles loc above 199, pick next with all others.
     *      Then everything else.

     *        Note, by setting everything else to 80, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 80, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 80

     C                   endsl

520g C     endjor        endsr
520dA*----------------------------------------------------------------
520dA*  palmerseq -  Special sequencing for Jack Palmer
520dA*----------------------------------------------------------------
520dA
520dAC     palmerseq     begsr
520dAC                   eval      iflag = *off
520dA
520dA*    Only update DRY and REF labels.

520d C                   if        lbwhdp <> 'D'
520dAC                             and lbwhdp <> 'R'
520d C                   eval      iflag = *on
520d C                   goto      endpalmer
520d C                   endif
520dA
520dA*    Only update type 'O' labels.
520dA
520dAC                   if        lbtype <> 'O'
520dAC                   eval      iflag = *on
520dAC                   goto      endpalmer
520dAC                   endif
520dA
520dA*    Retrieve corresponding WORKLBL record.
520dA
730dDC**   lblbl#        chain     worklbl
730dM /free
730dM                    chain (lbwhse: lblbl#) worklblw;
730dM /end-free
520dAC                   if        not %found
520dAC                   eval      lwszon = *blanks
520dAC                   endif

     *    Update LBLVL2 field, which will set the picking order in LABEL32C

520d C                   select

520dAC                   when      lwszon = 'DRYFR' and lwwhdp = 'R'
520dAC                   eval      lblvl2 = 1

520dAC                   other
520dAC                   eval      lblvl2 = 99

520dAC                   endsl

520dAC     endpalmer     endsr

SVL A*----------------------------------------------------------------
SVL A*  svlseq  -  Special sequencing for Saval
SVL A*----------------------------------------------------------------
SVL A
SVL AC     svlseq        begsr
     C                   eval      iflag = *off

     *    Only update DRY type 'O' labels.

     C                   if        (lbwhdp <> '2'
     C                             and lbwhdp <> '3')
     C                             or lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endsvl
     C                   endif

     C                   if        lbaisl <> *blanks
     C                   eval      temp1a = %subst(%trim(lbaisl):1:1)
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Pick aisle 'B'(starts with B) first.

     C                   when      temp1a = 'B'
     C                   eval      lblvl2 = 1

     *      Pick dept REF

     C*                  when      lwwhdp = '3'
     C*                            and lwaisl <> 'XDK'
     C                   when      temp1a = 'C'
     C                   eval      lblvl2 = 2

     *      Pick aisle 'D'(starts with D)

     C                   when      temp1a = 'D'
TPCaMC                   eval      lblvl2 = 3

     *      Then everything else.

     *        Note, by setting everything else to 80, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 80, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 80

     C                   endsl

SVL  C     endsvl        endsr
520eA*----------------------------------------------------------------
520eA*  royalseq -  Special sequencing for Royal
520eA*----------------------------------------------------------------
520eA
520eAC     royalseq      begsr
520eAC                   eval      iflag = *off

     *    Set up custom sequence for use with LABEL32C.

520eAC                   select

520eA*      Pick dept FRZ first.

520eAC                   when      lbwhdp = 'FRZ'
520eAC                   eval      lblvl2 = 5
520eA
520eA*      ...then CLR.
520eAC                   when      lbwhdp = 'CLR'
520eAC                   eval      lblvl2 = 10
520eA
520eA*      ...then DRY.
520eAC                   when      lbwhdp = 'DRY'
520eAC                   eval      lblvl2 = 15

520eAC                   other
520eAC                   eval      lblvl2 = 99

520eAC                   endsl
520eA

520eAC     endroyal      endsr
SBR A
SBR A*----------------------------------------------------------------
SBR A*  SBertramSeq -  Special sequencing for S Bertram
SBR A*----------------------------------------------------------------
SBR A
SBR AC     SBertramSeq   begsr
SBR AC                   eval      iflag = *off
SBR A
SBR A*    Only update type 'O' labels.
SBR A
SBR AC                   if        lbtype <> 'O'
SBR AC                   eval      iflag = *on
SBR AC                   goto      endSBertram
SBR AC                   endif
SBR A
SBR A*    Set up custom sequence for use with LABEL32C.
SBR A
SBR AC                   select
SBR A
SBReD *      Added cereal aisle 14-600 thru 14-633
SBReA
SBReAC                   when      lbwhdp = 'DRY'
SBReA
SBReAC                   select
SBReA
SBReAC                   when          lbaisl = ' 14'
SBReAC                             and lbloc >= 600
SBReAC                             and lbloc <= 633
SBReAC                   eval      lblvl2 = 51
SBReA *
SBReDC                   other
SBReDC                   eval      lblvl2 = 50
SBReA
SBReDC                   endsl
SBReA
SBR A*      Pick dept DRY, aisles 19 - 10, descending.
SBRdD*      Removed DRY 10/26/15.
SBR A
SBRdDC*                  when      lbwhdp = 'DRY'
SBR A
SBRdDC*                  select
SBRdDC*                  when      lbaisl = ' 19'
SBRdDC*                  eval      lblvl2 = 1
SBRdDC*                  eval      lblvl2 = 27
SBR A*
SBRdDC*                  when      lbaisl = ' 18'
SBRbDC*                  eval      lblvl2 = 3
SBRdDC*                  eval      lblvl2 = 25
SBR A*
SBR AC*                  when      lbaisl = ' 17'
SBRbDC*                  eval      lblvl2 = 5
SBRdDC*                  eval      lblvl2 = 29
SBR A*
SBRdDC*                  when      lbaisl = ' 16'
SBRbDC*                  eval      lblvl2 = 7
SBRdDC*                  eval      lblvl2 = 1
SBR A*
SBRdDC*                  when      lbaisl = ' 15'
SBRbDC*                  eval      lblvl2 = 9
SBRdDC*                  eval      lblvl2 = 3
SBRbA*
SBRdDC*                  when          lbaisl = ' 14'
SBRdDC*                            and lbloc >= 402
SBRdDC*                            and lbloc <= 699
SBRdDC*                  eval      lblvl2 = 21
SBR A*
SBRdDC*                  when          lbaisl = ' 14'
SBRdDC*                            and lbloc >= 100
SBRbDC*                            and lbloc <= 399
SBRdDC*                            and lbloc <= 219
SBRdDC*                  eval      lblvl2 = 11
SBRdDC*                  eval      lblvl2 = 23
SBR A*
SBRdDC*                  when          lbaisl = ' 13'
SBRbDC*                  eval      lblvl2 = 13
SBRdDC*                  eval      lblvl2 = 19
SBR A*
SBRdDC*                  when          lbaisl = ' 12'
SBRbDC*                            and lbloc >= 100
SBRdDC*                            and lbloc >= 102
SBRbDC*                            and lbloc <= 399
SBRdDC*                            and lbloc <= 195
SBRbDC*                  eval      lblvl2 = 15
SBRdDC*                  eval      lblvl2 = 11
SBRbA*
SBRdDC*                  when          lbaisl = ' 12'
SBRdDC*                            and lbloc >= 201
SBRdDC*                            and lbloc <= 213
SBRdDC*                  eval      lblvl2 = 17
SBRbA*
SBRdDC*                  when          lbaisl = ' 12'
SBRdDC*                            and lbloc >= 602
SBRdDC*                            and lbloc <= 627
SBRdDC*                  eval      lblvl2 = 9
SBR A*
SBRdDC*                  when          lbaisl = ' 11'
SBRdDC*                            and lbloc >= 100
SBRdDC*                            and lbloc <= 599
SBRbDC**                 eval      lblvl2 = 17
SBRdDC*                  eval      lblvl2 = 13
SBR A*
SBRdDC*                  when          lbaisl = ' 10'
SBRdDC*                                and lbloc >= 601
SBRdDC*                                and lbloc <= 620
SBRbDC**                 eval      lblvl2 = 19
SBRdDC*                  eval      lblvl2 = 5
SBRbA*
SBRbDC*                  when          lbaisl = ' 10'
SBRbDC*                                and lbloc >= 101
SBRbDC*                                and lbloc <= 139
SBRbDC*                  eval      lblvl2 = 15
SBR A*
SBRdDC*                  when          lbaisl = ' 11'
SBRbDC*                            and lbloc >= 600
SBRdDC*                            and lbloc >= 603
SBRbDC*                            and lbloc <= 999
SBRdDC*                            and lbloc <= 622
SBRbDC*                  eval      lblvl2 = 21
SBRdDC*                  eval      lblvl2 = 7
SBR A*
SBRbDC*                  when         (lbaisl = ' 12'
SBRbDC*                             or lbaisl = ' 14')
SBRbDC*                            and lbloc >= 400
SBRbDC*                            and lbloc <= 999
SBRbDC*                  eval      lblvl2 = 23
SBR A*
SBRdDC*                  other
SBRdDC*                  eval      lblvl2 = 50
SBRdDC*                  endsl
SBRcA
SBRcA*      Pick dept FRZ, aisles 41 - 47.
SBRcA
SBRcAC                   when      lbwhdp = 'FRZ'
SBRcA
SBRcAC                   select
SBRcAC                   when      lbaisl = ' 47'
SBRcAC                   eval      lblvl2 = 1
SBRcA*
SBRcAC                   when      lbaisl = ' 46'
SBRcAC                   eval      lblvl2 = 3
SBRcA*
SBRcAC                   when      lbaisl = ' 41'
SBRcAC                   eval      lblvl2 = 5
SBRcA*
SBRcAC                   when      lbaisl = ' 44'
SBRcAC                   eval      lblvl2 = 7
SBRcA*
SBRcAC                   when      lbaisl = ' 42'
SBRcAC                   eval      lblvl2 = 9
SBRcA*
SBRcAC                   when      lbaisl = ' 45'
SBRcAC                   eval      lblvl2 = 11
SBRcA*
SBRcAC                   when      lbaisl = ' 43'
SBRcAC                   eval      lblvl2 = 13
SBRcA*
SBRcAC                   other
SBRcAC                   eval      lblvl2 = 50
SBRcAC                   endsl
SBR A*
SBR A*      Then everything else.
SBR A
SBR A*        Note, by setting everything else to 50, the normal Aisle,
SBR A*        Picking Seq. order takes affect. Also, by using 50, the
SBR A*        possibility is left open to assign an aisle to be picked last
SBR A
SBR AC                   other
SBR AC                   eval      lblvl2 = 50
SBR A
SBR AC                   endsl
SBR A
SBR AC     endSBertram   endsr
SBR A*
WIL A*----------------------------------------------------------------
WIL A*  WillFoodSeq -  Special sequencing for Will Foods
WIL A*----------------------------------------------------------------
WIL A
WIL AC     WillFoodSeq   begsr
WIL AC                   eval      iflag = *off
WIL A
WIL A*    Only update type 'O' labels.
WIL A
WIL AC                   if        lbtype <> 'O'
WIL AC                   eval      iflag = *on
WIL AC                   goto      endWillFood
WIL AC                   endif
WILcA
WILcA*    Retrieve corresponding SLOT2 record for aisle 51.
WILcA
WILcAC                   if        lbaisl = ' 51'
WILcAC     keysl2        chain     slot2
WILcAC                   if        not %found
WILcAC                   eval      slside = 0
WILcAC                   endif
WilcAC                   endif
WIL A
WIL A*    Set up custom sequence for use with LABEL32C.
WIL A
WIL AC                   select
WIL A
WIL A*      Pick dept D.
WIL A
WIL AC                   when      lbwhdp = 'D'
WIL A
WIL AC                   select
WIL AC                   when      lbaisl = ' 70'
WIL AC                   eval      lblvl2 = 1
WIL A*
WIL AC                   when         (lbaisl >= ' 71'
WILbMC                             and lbaisl <= ' 71')
WIL AC                   eval      lblvl2 = 5
WILbA*
WILbAC                   when         (lbaisl >= ' 72'
WILbAC                             and lbaisl <= ' 72')
WILbAC                   eval      lblvl2 = 15
WILdA*
WILdAC                   when         (lbaisl >= ' 80'
WILdAC                             and lbaisl <= ' 80')
WILdAC                   eval      lblvl2 = 27
WIL A*
WIL AC                   when         (lbaisl >= ' 81'
WIL AC                             and lbaisl <= ' 85')
WILbMC                   eval      lblvl2 = 30
WIL A*
WIL AC                   other
WIL AC                   eval      lblvl2 = 50
WIL AC                   endsl
WIL A
WIL A*      Pick dept F.
WIL A
WIL AC                   when      lbwhdp = 'F'
WIL A
WIL AC                   select
WILaAC                   when         (lbaisl >= ' 40'
WILaAC                             and lbaisl <= ' 42')
WILaAC                   eval      lblvl2 = 1
WILaA*
WILaAC                   when         (lbaisl >= ' 10'
WILaAC                             and lbaisl <= ' 13')
WILaAC                   eval      lblvl2 = 5
WIL A*
WIL AC                   other
WIL AC                   eval      lblvl2 = 50
WIL AC                   endsl
WIL A
WIL A*      Pick dept R.
WIL A
WIL AC                   when      lbwhdp = 'R'
WIL A
WIL AC                   select
WIL AC                   when         (lbaisl >= ' 50'
WILcDC*                            and lbaisl <= ' 51')
WILcMC                             and lbaisl <= ' 50')
WILbMC                   eval      lblvl2 = 20
WILcA*
WILcAC                   when         (lbaisl >= ' 51'
WILcAC                             and lbaisl <= ' 51')
WILcAC                             and (lbloc >= 223
WILcAC                              and lbloc <= 243)
WILcAC                              and slside = 1
WILcAC                   eval      lblvl2 = 50
WILcA*
WILcAC                   when         (lbaisl >= ' 51'
WILcAC                             and lbaisl <= ' 51')
WILcAC                   eval      lblvl2 = 20
WIL A*
WIL AC                   when         (lbaisl >= ' 60'
WIL AC                             and lbaisl <= ' 61')
WILbMC                   eval      lblvl2 = 25
WIL A*
WIL AC                   when         (lbaisl >= ' 71'
WILbMC                             and lbaisl <= ' 71')
WIL AC                   eval      lblvl2 = 5
WILbA*
WILbAC                   when         (lbaisl >= ' 72'
WILbAC                             and lbaisl <= ' 72')
WILbAC                   eval      lblvl2 = 10
WIL A*
WIL AC                   other
WIL AC                   eval      lblvl2 = 50
WIL AC                   endsl
WIL A*
WIL A*      Then everything else.
WIL A
WIL A*        Note, by setting everything else to 50, the normal Aisle,
WIL A*        Picking Seq. order takes affect. Also, by using 50, the
WIL A*        possibility is left open to assign an aisle to be picked last
WIL A
WIL AC                   other
WIL AC                   eval      lblvl2 = 50
WIL A
WIL AC                   endsl
WIL A
WIL AC     endWillfood   endsr
WIL A*
PAN A*----------------------------------------------------------------
PAN A*  PanosSeq -  Special sequencing for Panos Foods
PAN A*----------------------------------------------------------------
PAN A
PAN AC     Panosseq      begsr
PAN AC                   eval      iflag = *off
PAN A
PAN A*    Only update type 'O' labels.
PAN A
PAN AC                   if        lbtype <> 'O'
PAN AC                   eval      iflag = *on
PAN AC                   goto      endPanos
PAN AC                   endif
PAN A
PAN A*    Set up custom sequence for use with LABEL32C.
PAN A
PAN AC                   select
PAN A
PAN A*      Pick dept DRY.
PAN A
PAN AC                   when      lbwhdp = 'D'
PAN AC                   eval      lblvl2 = 30
PAN A*
PAN A
PAN A*      Pick dept FRZ.
PAN A
PAN AC                   when      lbwhdp = 'F'
PAN AC                   eval      lblvl2 = 10
PAN A
PAN A*      Pick dept REF.
PAN A
PAN AC                   when      lbwhdp = 'R'
PAN AC                   eval      lblvl2 = 20
PAN A*
PAN A*      Then everything else.
PAN A
PAN A*        Note, by setting everything else to 50, the normal Aisle,
PAN A*        Picking Seq. order takes affect. Also, by using 50, the
PAN A*        possibility is left open to assign an aisle to be picked last
PAN A
PAN AC                   other
PAN AC                   eval      lblvl2 = 50
PAN A
PAN AC                   endsl
PAN A
PAN AC     endPanos      endsr
PAN A*
FPR A*----------------------------------------------------------------
FPR A*  FoodProSeq -  Special sequencing for FoodPro
FPR A*----------------------------------------------------------------
FPR A
FPR AC     foodProSeq    begsr
FPR AC                   eval      iflag = *off
FPR A
FPR A*    Only update type 'O' labels.
FPR A
FPR AC                   if        lbtype <> 'O'
FPR AC                   eval      iflag = *on
FPR AC                   goto      endFoodPro
FPR AC                   endif
FPR A
FPR A*    Set up custom sequence for use with LABEL32D.
FPR A
FPR AC                   select
FPR A
FPR A*      Pick dept DRY.
FPR A
FPR AC                   when      lbwhdp = 'DRY'
FPRbDC*                  eval      lblvl2 = 1
FPRbAC                   select
FPRbAC                   when      lbaisl = ' DP'
FPRbAC                   eval      lblvl2 = 10
FPRbAC                   when      lbaisl = ' DQ'
FPRbAC                   eval      lblvl2 = 11
FPRbAC                   when      lbaisl = ' DR'
FPRbAC                   eval      lblvl2 = 12
FPRbAC                   when      lbaisl = ' DS'
FPRbAC                   eval      lblvl2 = 13
FPRbAC                   when      lbaisl = ' DT'
FPRbAC                   eval      lblvl2 = 14
FPRbAC                   when      lbaisl = ' DV'
FPRbAC                   eval      lblvl2 = 15
FPRbAC*                  when      lbaisl > ' DP' or
FPRbAC*                            lbaisl < ' JU'
FPRbAC*                  eval      lblvl2 = 10
FPRbAC                   when      lbaisl > ' DV'
FPRbAC                   eval      lblvl2 = 30
FPRbAC                   other
FPRbAC                   eval      lblvl2 = 50
FPRbAC                   endsl
FPR A*
FPR A*      Pick dept CLR.
FPR A
FPR AC                   when      lbwhdp = 'CLR'
FPRbDC*                  eval      lblvl2 = 5
FPRbAC                   select
FPRbAC                   when      lbaisl = ' CF'
FPRbAC                   eval      lblvl2 = 5
FPRbAC*                  when      lbaisl > ' CF'
FPRbAC                   when      lbaisl = ' JA'
FPRbAC                   eval      lblvl2 = 20
FPRbAC                   when      lbaisl = ' JB'
FPRbAC                   eval      lblvl2 = 21
FPRbAC                   when      lbaisl = ' JC'
FPRbAC                   eval      lblvl2 = 22
FPRbAC                   when      lbaisl = ' JD'
FPRbAC                   eval      lblvl2 = 23
FPRbAC                   when      lbaisl = ' JE'
FPRbAC                   eval      lblvl2 = 24
FPRbAC                   when      lbaisl = ' JF'
FPRbAC                   eval      lblvl2 = 25
FPRbAC                   when      lbaisl = ' JG'
FPRbAC                   eval      lblvl2 = 26
FPRbAC                   when      lbaisl = ' JH'
FPRbAC                   eval      lblvl2 = 27
FPRbAC                   when      lbaisl = ' JJ'
FPRbAC                   eval      lblvl2 = 28
FPRbAC                   when      lbaisl = ' JK'
FPRbAC                   eval      lblvl2 = 29
FPRbAC                   other
FPRbAC                   eval      lblvl2 = 50
FPRbAC                   endsl
FPR A*
FPR A*      Then everything else.
FPR A
FPR A*        Note, by setting everything else to 50, the normal Aisle,
FPR A*        Picking Seq. order takes affect. Also, by using 50, the
FPR A*        possibility is left open to assign an aisle to be picked last
FPR A
FPR AC                   other
FPR AC                   eval      lblvl2 = 50
FPR A
FPR AC                   endsl
FPR A
FPR AC     endFoodPro    endsr
RNZ A
RNZ A*----------------------------------------------------------------
RNZ A*  renziseq -  Special sequencing for Renzi
RNZ A*----------------------------------------------------------------
RNZ A
RNZ AC     renziseq      begsr
RNZ AC                   eval      iflag = *off
RNZ A
RNZ A*    Only update department DRY type 'O' labels.
RNZ A
RNZ AC                   if        (lbwhdp <> 'DRY'
RNZ AC                             and lbwhdp <> 'CLR')
RNZ AC                   eval      iflag = *on
RNZ AC                   goto      endrenzi
RNZ AC                   endif
RNZ A
RNZ A*    Set up custom sequence for use with LABEL32D.
RNZ A
RNZ AC                   select
RNZ A
RNZ A*      When Department Dry
RNZ A
RNZ AC                   when      lbwhdp= 'DRY'
RNZ A
RNZ AC                   select
RNZ A
RNZ A*      Pick aisle  N
RNZ A
RNZ AC                   when      lbaisl = '  N'
RNZ AC                   eval      lblvl2 = 5
RNZ A
RNZ A*      Pick aisle  P
RNZ A
RNZ AC                   when      lbaisl = '  P'
RNZ AC                   eval      lblvl2 = 10
RNZ A
RNZ A*      Pick aisle  D
RNZ A
RNZ AC                   when      lbaisl = '  D'
RNZ AC                   eval      lblvl2 = 25
RNZ A
RNZ A*      Pick aisle  R - X
RNZ A
RNZ AC                   when          lbaisl >= '  R'
RNZ AC                             and lbaisl <= '  X'
RNZ AC                   eval      lblvl2 = 30
RNZ A
RNZ A
RNZ A*      Then everything else.
RNZ A
RNZ A*        Note, by setting everything else to 50, the normal Aisle,
RNZ A*        Picking Seq. order takes affect. Also, by using 50, the
RNZ A*        possibility is left open to assign an aisle to be picked last
RNZ A
RNZ AC                   other
RNZ AC                   eval      lblvl2 = 50
RNZ A
RNZ AC                   endsl
RNZ A
RNZ A*      When Department CLR
RNZ A
RNZ AC                   when      lbwhdp= 'CLR'
RNZ A
RNZ AC                   select
RNZ A
RNZ A*      Pick aisles  L - N
RNZ A
RNZ AC                   when          lbaisl >= '  L'
RNZ AC                             and lbaisl <= '  N'
RNZ AC                   eval      lblvl2 = 1
RNZ A
RNZ A*      Pick aisle  P
RNZ A
RNZ AC                   when      lbaisl = '  P'
RNZ AC                   eval      lblvl2 = 15
RNZ A
RNZ A*      Pick aisle  R
RNZ A
RNZ AC                   when      lbaisl = '  R'
RNZ AC                   eval      lblvl2 = 20
RNZ A
RNZ A*      Pick aisle  Q
RNZ A
RNZ AC                   when      lbaisl = '  Q'
RNZ AC                   eval      lblvl2 = 35
RNZ A
RNZ A*      Then everything else.
RNZ A
RNZ A*        Note, by setting everything else to 50, the normal Aisle,
RNZ A*        Picking Seq. order takes affect. Also, by using 50, the
RNZ A*        possibility is left open to assign an aisle to be picked last
RNZ A
RNZ AC                   other
RNZ AC                   eval      lblvl2 = 50
RNZ AC                   endsl
RNZ A
RNZ AC                   endsl
RNZ A
RNZ AC     endrenzi      endsr
ADF A
ADF A*----------------------------------------------------------------
ADF A*  ADFoodsseq -  Special sequencing for A&D Foods
ADF A*----------------------------------------------------------------
ADF A
ADF AC     adfoodsseq    begsr
ADF AC                   eval      iflag = *off
ADF A
ADF A*    Set up custom sequence for use with LABEL32D.
ADF A
ADF AC                   select
ADF A
ADF A*      When Department F=Freezer
ADF A
ADF AC                   when      lbwhdp= 'F'
ADFaAC                   select
ADFaAC                   when          lbaisl = ' 1G'
ADFaAC                             and lbloc >= 100
ADFaAC                             and lbloc <= 128
ADFaMC                   eval      lblvl2 = 1
ADFaA
ADFaAC                   when          lbaisl = ' 1F'
ADFaAC                             and lbloc >= 100
ADFaAC                             and lbloc <= 128
ADFaMC                   eval      lblvl2 = 3
ADFaA
ADFaAC                   when          lbaisl = ' 1E'
ADFaAC                             and lbloc >= 100
ADFaAC                             and lbloc <= 128
ADFaMC                   eval      lblvl2 = 5
ADFaA
ADFaAC                   when          lbaisl = ' 1D'
ADFaAC                             and lbloc >= 100
ADFaAC                             and lbloc <= 128
ADFaMC                   eval      lblvl2 = 7
ADFaA
ADFaAC                   when          lbaisl = ' 1C'
ADFaAC                             and lbloc >= 100
ADFaAC                             and lbloc <= 128
ADFaMC                   eval      lblvl2 = 9
ADFaA
ADFaAC                   when          lbaisl = ' 1B'
ADFaAC                             and lbloc >= 100
ADFaAC                             and lbloc <= 128
ADFaMC                   eval      lblvl2 = 11
ADFaA
ADFaAC                   when          lbaisl = ' 1A'
ADFaAC                             and lbloc >= 100
ADFaMC                   eval      lblvl2 = 13
ADFaA
ADFaAC                   when          lbaisl = ' 1B'
ADFaAC                             and lbloc >= 135
ADFaMC                   eval      lblvl2 = 15
ADFaA
ADFaAC                   when          lbaisl = ' 1C'
ADFaAC                             and lbloc >= 135
ADFaMC                   eval      lblvl2 = 17
ADFaA
ADFaAC                   when          lbaisl = ' 1D'
ADFaAC                             and lbloc >= 135
ADFaMC                   eval      lblvl2 = 19
ADFaA
ADFaAC                   when          lbaisl = ' 1E'
ADFaAC                             and lbloc >= 135
ADFaMC                   eval      lblvl2 = 21
ADFaA
ADFaAC                   when          lbaisl = ' 1F'
ADFaAC                             and lbloc >= 135
ADFaMC                   eval      lblvl2 = 23
ADFaA
ADFaAC                   when          lbaisl = ' 1G'
ADFaAC                             and lbloc >= 135
ADFaMC                   eval      lblvl2 = 25
ADFaA
ADFaAC                   other
ADFaAC                   eval      lblvl2 = 30
ADFaAC                   endsl
ADF A
ADF A*      When Department R=Refrigerated
ADF A
ADF AC                   when      lbwhdp= 'R'
ADFaDC*                  eval      lblvl2 = 10
ADFaMC                   eval      lblvl2 = 40
ADF A
ADF A*      When Department D=Dry
ADF A
ADF AC                   when      lbwhdp= 'D'
ADFaDC*                  eval      lblvl2 = 15
ADFaMC                   eval      lblvl2 = 45
ADF A
ADF A*      Then everything else.
ADF A
ADF A*        Note, by setting everything else to 50, the normal Aisle,
ADF A*        Picking Seq. order takes affect. Also, by using 50, the
ADF A*        possibility is left open to assign an aisle to be picked last
ADF A
ADF AC                   other
ADF AC                   eval      lblvl2 = 50
ADF AC                   endsl
ADF A
ADF AC     endadfoods    endsr
ADF A
FGL A*----------------------------------------------------------------
FGL A*  FGLseq -  Special sequencing for Foods Galore
FGL A*----------------------------------------------------------------
FGL A
FGL AC     fglseq        begsr
FGL AC                   eval      iflag = *off
FGL A
FGL A*    Set up custom sequence for use with LABEL32C.
FGL A
FGL AC                   select
FGL A
FGL A*      When Department DRY
FGL AC                   when      lbwhdp= 'DRY'
FGL AC                   eval      lblvl2 = 50
FGL A
FGL A*      When Department FRZ = Freezer
FGL A
FGL AC                   when      lbwhdp= 'FRZ'
FGL AC                   select
FGL AC                   when          lbaisl  = ' 35'
FGL AC                             or  lbaisl  = ' 36'
FGL AC                             or  lbaisl >= ' 38'
FGL AC                             and lbaisl <= ' 42'
FGL AC                   eval      lblvl2 = 5
FGL A*
FGL AC                   when          lbaisl  = ' 09'
FGL AC                   eval      lblvl2 = 10
FGL A*
FGL AC                   other
FGL AC                   eval      lblvl2 = 50
FGL A*
FGL AC                   endsl
FGL A
FGL A*      When Department REF = Refrigerated
FGL A
FGL AC                   when      lbwhdp= 'REF'
FGL AC                   eval      lblvl2 = 50
FGL A
FGL A*      Then everything else.
FGL A
FGL A*        Note, by setting everything else to 50, the normal Aisle,
FGL A*        Picking Seq. order takes affect. Also, by using 50, the
FGL A*        possibility is left open to assign an aisle to be picked last
FGL A
FGL AC                   other
FGL AC                   eval      lblvl2 = 50
FGL AC                   endsl
FGL A
FGL AC     endFGLseq     endsr
FGL A
GRC A*----------------------------------------------------------------
GRC A*  GRCseq -  Special sequencing for Greco & Sons
GRC A*----------------------------------------------------------------
GRC A
GRC AC     grcseq        begsr
GRC AC                   eval      iflag = *off
GRC A
GRC A*    Set up custom sequence for use with LABEL32D.
GRC A
GRC AC                   select
GRC A
GRC A*      When Department D=Dry
GRC AC                   when      lbwhdp= 'D'
GRC AC                   select
GRC AC                   when          lbaisl  = ' DA'
GRC AC                   eval      lblvl2 = 1
GRC A*
GRC AC                   when          lbaisl >= ' BA'
GRC AC                             and lbaisl <= ' BF'
GRC AC                   eval      lblvl2 = 3
GRC A*
GRC AC                   when          lbaisl  = ' DI'
GRC AC                   eval      lblvl2 = 6
GRC A*
GRC AC                   when          lbaisl  = ' DH'
GRC AC                   eval      lblvl2 = 9
GRC A*
GRC AC                   when          lbaisl  = ' DG'
GRC AC                   eval      lblvl2 = 12
GRC A*
GRC AC                   when          lbaisl  = ' DF'
GRC AC                   eval      lblvl2 = 15
GRC A*
GRC AC                   when          lbaisl  = ' DE'
GRC AC                   eval      lblvl2 = 18
GRC A*
GRC AC                   when          lbaisl  = ' DD'
GRC AC                   eval      lblvl2 = 21
GRC A*
GRC AC                   when          lbaisl  = ' DC'
GRC AC                   eval      lblvl2 = 24
GRC A*
GRC AC                   when          lbaisl  = ' DB'
GRC AC                   eval      lblvl2 = 27
GRCaA*
GRCaAC                   when          lbaisl  = 'DSP'
GRCaAC                   eval      lblvl2 = 60
GRCaA*
GRCaAC                   when          lbaisl  = ' RM'
GRCaAC                   eval      lblvl2 = 63
GRCaA*
GRCaAC                   when          lbaisl  = 'DDK'
GRCaAC                   eval      lblvl2 = 64
GRCaA*
GRCaAC                   when          lbaisl  = 'PDK'
GRCaAC                   eval      lblvl2 = 65
GRCaA*
GRCaAC                   when          lbaisl  = ' GL'
GRCaAC                   eval      lblvl2 = 67
GRC A*
GRC AC                   other
GRC AC                   eval      lblvl2 = 70
GRC AC                   endsl
GRC A
GRC A*      When Department R=Refrigerated
GRC A
GRC AC                   when      lbwhdp= 'R'
GRC AC                   select
GRC AC                   when          lbaisl >= ' CA'
GRC AC                             and lbaisl <= ' CC'
GRC AC                   eval      lblvl2 = 30
GRC A*
GRC AC                   when          lbaisl  = ' MC'
GRC AC                             and lbloc  >= 0
GRC AC                             and lbloc  <= 036
GRC AC                   eval      lblvl2 = 33
GRC A*
GRC AC                   when          lbaisl >= ' CD'
GRC AC                             and lbaisl <= ' CE'
GRC AC                   eval      lblvl2 = 36
GRC A*
GRC AC                   when          lbaisl  = ' MC'
GRC AC                             and lbloc  >= 037
GRC AC                             and lbloc  <= 999
GRC AC                   eval      lblvl2 = 39
GRC A*
GRC AC                   when          lbaisl >= ' PA'
GRC AC                             and lbaisl <= ' PF'
GRC AC                   eval      lblvl2 = 52
GRCaA*
GRCaAC                   when          lbaisl  = 'CSP'
GRCaAC                   eval      lblvl2 = 61
GRCaA*
GRCaAC                   when          lbaisl  = 'CDK'
GRCaAC                   eval      lblvl2 = 66
GRC A*
GRC AC                   other
GRC AC                   eval      lblvl2 = 70
GRC A*
GRC AC                   endsl
GRC A
GRC A*      When Department F=Freezer
GRC A
GRC AC                   when      lbwhdp= 'F'
GRC AC                   select
GRC AC                   when          lbaisl >= ' FA'
GRC AC                             and lbaisl <= ' FC'
GRC AC                   eval      lblvl2 = 42
GRC A*
GRC AC                   when          lbaisl >= ' FE'
GRC AC                             and lbaisl <= ' FJ'
GRC AC                   eval      lblvl2 = 45
GRC A*
GRC AC                   when          lbaisl  = ' FD'
GRC AC                   eval      lblvl2 = 48
GRCaA*
GRCaAC                   when          lbaisl  = 'FSP'
GRCaAC                   eval      lblvl2 = 62
GRC A*
GRC AC                   other
GRC AC                   eval      lblvl2 = 70
GRC A*
GRC AC                   endsl
GRC A
GRC A*      Then everything else.
GRC A
GRC A*        Note, by setting everything else to 60, the normal Aisle,
GRC A*        Picking Seq. order takes affect. Also, by using 60, the
GRC A*        possibility is left open to assign an aisle to be picked last
GRC A
GRC AC                   other
GRC AC                   eval      lblvl2 = 70
GRC AC                   endsl
GRC A
GRC AC     endGRCseq     endsr
GRC A
TNT A*----------------------------------------------------------------
TNT A*  TNTseq -  Special sequencing for TnT Produce
TNT A*----------------------------------------------------------------
TNT A
TNT AC     tntseq        begsr
TNT AC                   eval      iflag = *off
TNT A
TNT A*    Set up custom sequence for use with LABEL32C.
TNT A
TNT AC                   select
TNT A
TNT A*      When Department DRY
TNT AC                   when      lbwhdp= 'DRY'
TNT AC                   eval      lblvl2 = 80
TNT A
TNT A*      When Department FRZ
TNT AC                   when      lbwhdp= 'FRZ'
TNT AC                   eval      lblvl2 = 80
TNT A
TNT A*      When Department CLR = Cooler
TNT A
TNT AC                   when      lbwhdp= 'CLR'
TNT AC                   select
TNT AC                   when          lbaisl >= ' 10'
TNT AC                             and lbaisl <= ' 11'
TNT AC                   eval      lblvl2 = 5
TNT A*
TNT AC                   when          lbaisl >= ' 50'
TNT AC                             and lbaisl <= ' 55'
TNT AC                   eval      lblvl2 = 10
TNT A*
TNT AC                   when          lbaisl >= ' 61'
TNT AC                             and lbaisl <= ' 62'
TNT AC                   eval      lblvl2 = 15
TNT A*
TNT AC                   when          lbaisl >= ' 71'
TNT AC                             and lbaisl <= ' 72'
TNT AC                   eval      lblvl2 = 20
TNT A*
TNT AC                   when          lbaisl >= ' 12'
TNT AC                             and lbaisl <= ' 14'
TNT AC                   eval      lblvl2 = 25
TNT A*
TNT AC                   when          lbaisl >= ' 31'
TNT AC                             and lbaisl <= ' 33'
TNT AC                   eval      lblvl2 = 30
TNT A*
TNT AC                   when          lbaisl  = ' 15'
TNT AC                   eval      lblvl2 = 35
TNT A*
TNT AC                   when          lbaisl >= ' 40'
TNT AC                             and lbaisl <= ' 45'
TNT AC                   eval      lblvl2 = 40
TNT A*
TNT AC                   when          lbaisl  = ' 16'
TNT AC                   eval      lblvl2 = 45
TNT A*
TNT AC                   when          lbaisl  = ' 19'
TNT AC                   eval      lblvl2 = 50
TNT A*
TNT AC                   when          lbaisl  = ' 17'
TNT AC                   eval      lblvl2 = 55
TNT A*
TNT AC                   when          lbaisl  = ' 18'
TNT AC                   eval      lblvl2 = 60
TNT A*
TNT AC                   when          lbaisl  = ' 99'
TNT AC                   eval      lblvl2 = 65
TNT A*
TNT AC                   other
TNT AC                   eval      lblvl2 = 80
TNT A*
TNT AC                   endsl
TNT A
TNT A*      Then everything else.
TNT A
TNT A*        Note, by setting everything else to 80, the normal Aisle,
TNT A*        Picking Seq. order takes affect. Also, by using 80, the
TNT A*        possibility is left open to assign an aisle to be picked last
TNT A
TNT AC                   other
TNT AC                   eval      lblvl2 = 80
TNT AC                   endsl
TNT A
TNT AC     endTNTseq     endsr
TNT A
COT A*----------------------------------------------------------------
COT A*  COTseq -  Special sequencing for Cotati Foods
COT A*----------------------------------------------------------------
COT A
COT AC     cotseq        begsr
COT AC                   eval      iflag = *off
COT A
COT A*    Set up custom sequence for use with LABEL32C.
COT A
COT AC                   select
COT A
COT A*      When Department R = Refrigerated
COT AC                   when      lbwhdp= 'R'
COT AC                   eval      lblvl2 = 10
COT A
COT A*      When Department D = Dry
COT A
COT AC                   when      lbwhdp= 'D'
COT AC                   eval      lblvl2 = 20
COT A
COT A*      When Department REF = Refrigerated
COT A
COT AC                   when      lbwhdp= 'F'
COT AC                   eval      lblvl2 = 30
COT A
COT A*      Then everything else.
COT A
COT A*        Note, by setting everything else to 50, the normal Aisle,
COT A*        Picking Seq. order takes affect. Also, by using 50, the
COT A*        possibility is left open to assign an aisle to be picked last
COT A
COT AC                   other
COT AC                   eval      lblvl2 = 50
COT AC                   endsl
COT A
COT AC     endCOTseq     endsr
COT A
EOP A*----------------------------------------------------------------
EOP A*  EOPseq -  Special sequencing for Earl's Organic Foods
EOP A*----------------------------------------------------------------
EOP A
EOP AC     eopseq        begsr
EOP AC                   eval      iflag = *off
EOP A
EOP A*    Set up custom sequence for use with LABEL32C.
EOP A
EOP AC                   select
EOP A
EOP A*      When Department = REF
EOP AC                   when      lbwhdp= 'REF'
EOP A*
EOP AC                   select
EOP A*
EOPaAC                   when          lbaisl = 'CSO'
EOPaAC                   eval      lblvl2 = 1
EOPaA*
EOP AC                   when      lbaisl = 'BAN'
EOPaDC*                  eval      lblvl2 = 1
EOPaMC                   eval      lblvl2 = 2
EOP A*
EOP AC                   when          lbaisl = ' E1'
EOP AC                   eval      lblvl2 = 3
EOP A*
EOP AC                   when          lbaisl = ' A1'
EOP AC                   eval      lblvl2 = 5
EOP A*
EOP AC                   when          lbaisl = ' A5'
EOP AC                             and lbloc  >= 501
EOP AC                             and lbloc  <= 513
EOP AC                   eval      lblvl2 = 7
EOP A*
EOP AC                   when          lbaisl >= ' A2'
EOP AC                             and lbaisl <= ' A3'
EOP AC                   eval      lblvl2 = 9
EOP A*
EOP AC                   when          lbaisl = ' A5'
EOP AC                             and lbloc  >= 515
EOP AC                             and lbloc  <= 529
EOP AC                   eval      lblvl2 = 11
EOP A*
EOP AC                   when          lbaisl = ' A4'
EOP AC                   eval      lblvl2 = 13
EOP A*
EOP AC                   when          lbaisl = ' B1'
EOP AC                   eval      lblvl2 = 15
EOP A*
EOP AC                   when          lbaisl = ' B5'
EOP AC                             and lbloc  >= 501
EOP AC                             and lbloc  <= 521
EOP AC                   eval      lblvl2 = 17
EOP A*
EOP AC                   when          lbaisl >= ' B2'
EOP AC                             and lbaisl <= ' B3'
EOP AC                   eval      lblvl2 = 19
EOP A*
EOP AC                   when          lbaisl = ' B5'
EOP AC                             and lbloc  >= 523
EOP AC                             and lbloc  <= 525
EOP AC                   eval      lblvl2 = 21
EOP A*
EOP AC                   when          lbaisl = ' B9'
EOP AC                   eval      lblvl2 = 23
EOP A*
EOP AC                   when          lbaisl = ' C1'
EOP AC                   eval      lblvl2 = 25
EOP A*
EOP AC                   when          lbaisl = ' C5'
EOP AC                             and lbloc  >= 501
EOP AC                             and lbloc  <= 511
EOP AC                   eval      lblvl2 = 27
EOPaA*
EOPaAC                   when          lbaisl = ' C5'
EOPaAC                             and lbloc  >= 513
EOPaAC                             and lbloc  <= 515
EOPaAC                   eval      lblvl2 = 28
EOP A*
EOP AC                   when          lbaisl = ' C2'
EOP AC                   eval      lblvl2 = 29
EOP A*
EOP AC                   when          lbaisl = ' D1'
EOP AC                   eval      lblvl2 = 31
EOP A*
EOP AC                   when          lbaisl = ' D5'
EOP AC                             and lbloc  >= 501
EOP AC                             and lbloc  <= 509
EOP AC                   eval      lblvl2 = 33
EOP A*
EOP AC                   when          lbaisl = ' F1'
EOP AC                   eval      lblvl2 = 35
EOP A*
EOP AC                   when          lbaisl = 'GRC'
EOP AC                   eval      lblvl2 = 37
EOP A*
EOP AC                   when          lbaisl >= ' G1'
EOP AC                             and lbaisl <= ' G3'
EOP AC                   eval      lblvl2 = 39
EOP A*
EOP AC                   when          lbaisl = 'IBD'
EOP AC                   eval      lblvl2 = 41
EOP A*
EOP AC                   when          lbaisl = 'IBF'
EOP AC                   eval      lblvl2 = 43
EOP A*
EOP AC                   when          lbaisl = 'OBD'
EOP AC                   eval      lblvl2 = 45
EOP A*
EOP AC                   when          lbaisl = 'OBF'
EOP AC                   eval      lblvl2 = 47
EOP A*
EOP AC                   when          lbaisl = ' QC'
EOP AC                   eval      lblvl2 = 49
EOP A*
EOP AC                   when          lbaisl = 'RPK'
EOP AC                   eval      lblvl2 = 51
EOP A*
EOP AC                   when          lbaisl = 'SLD'
EOP AC                   eval      lblvl2 = 53
EOP A*
EOP AC                   when          lbaisl = 'STR'
EOP AC                   eval      lblvl2 = 55
EOP A*
EOP AC                   when          lbaisl = 'XDK'
EOP AC                   eval      lblvl2 = 57
EOP A*
EOP AC                   when          lbaisl = 'DMP'
EOP AC                   eval      lblvl2 = 59
EOP A*
EOP AC                   when          lbaisl = 'DSP'
EOP AC                   eval      lblvl2 = 61
EOPaD*
EOPaDC*                  when          lbaisl = 'CSO'
EOPaDC*                  eval      lblvl2 = 63
EOP A*
EOP AC                   when          lbaisl = 'BIN'
EOP AC                   eval      lblvl2 = 65
EOP A*
EOP AC                   when          lbaisl = ' B5'
EOP AC                             and lbloc  >= 506
EOP AC                             and lbloc  <= 520
EOP AC                   eval      lblvl2 = 67
EOP A*
EOP AC                   when          lbaisl = ' C5'
EOP AC                             and lbloc  >= 513
EOP AC                             and lbloc  <= 515
EOP AC                   eval      lblvl2 = 69
EOP A
EOP AC                   other
EOP AC                   eval      lblvl2 = 80
EOP AC                   endsl
EOP A*
EOP A*      Then everything else.
EOP A
EOP A*        Note, by setting everything else to 80, the normal Aisle,
EOP A*        Picking Seq. order takes affect. Also, by using 80, the
EOP A*        possibility is left open to assign an aisle to be picked last
EOP A
EOP AC                   other
EOP AC                   eval      lblvl2 = 80
EOP AC                   endsl
EOP A
EOP AC     endEOPseq     endsr
EOP A
MRT A*----------------------------------------------------------------
MRT A*  MRTseq -  Special sequencing for Merit Foods
MRT A*----------------------------------------------------------------
MRT A
MRT AC     mrtseq        begsr

MRTaAC     keyitem       chain     piritem
MRTaAC                   if        not %found(piritem)
MRTaAC                   eval      itdesg = *blanks
MRTaAC                   endif

MRTdAC     keyitemfld    chain     itemfld
MRTdAC                   if        not %found(itemfld)
MRTdAC                   eval      ifcat = *blanks
MRTdAC                   endif

MRT AC                   eval      iflag = *off
MRT A
MRT A*    Set up custom sequence for use with LABEL32D.
MRT A
MRT AC                   select
MRTaA
MRTaA*      When Chemical
MRTdAC                   when      ifcat = 'CHEM'
MRTdAC                   eval      lblvl2 = 5
MRT A
MRT A*      When Department D = Dry.
MRT AC                   when      lbwhdp= 'D'
MRT AC                   select
MRTaAC                   when          lbaisl >= ' 11'
MRTaAC                             and lbaisl <= ' 12'
MRTaMC                   eval      lblvl2 = 10
MRTaA*    backwards
MRTaAC                   when          lbaisl = ' 54'
MRTcD *                         ** and lbaisl <= ' 54'
MRTaAC                   eval      lblvl2 = 20
MRT A*
MRTcAC                   when          lbaisl = ' 53'
MRTcAC                   eval      lblvl2 = 21
MRT A*
MRTcAC                   when          lbaisl = ' 52'
MRTcAC                   eval      lblvl2 = 22
MRT A*
MRTcAC                   when          lbaisl = ' 51'
MRTcAC                   eval      lblvl2 = 23
MRTeA*
MRTeAC                   when          lbaisl = ' 82'
MRTeAC                   eval      lblvl2 = 49
MRT A*
MRT AC                   other
MRT AC                   eval      lblvl2 = 50
MRT A*
MRT AC                   endsl
MRT A
MRT A*      When Department F = Freezer
MRT A
MRT AC                   when      lbwhdp= 'F'
MRT AC                   select
MRT A*
MRTaAC                   when          lbaisl >= ' 71'
MRTaAC                             and lbaisl <= ' 77'
MRTaMC                   eval      lblvl2 = 2
MRT A*
MRTcAC                   when          lbaisl >= ' 90'
MRTcAC                             and lbaisl <= ' 92'
MRTcAC                   eval      lblvl2 = 48
MRT A*
MRT AC                   other
MRT AC                   eval      lblvl2 = 50
MRT A*
MRT AC                   endsl
MRT A
MRT A*      When Department R = Refrigerated
MRT A
MRT AC                   when      lbwhdp= 'R'
MRT AC                   select
MRTaA*      When Department R and Chicken Room
MRTaAC                   when          lbaisl = ' 21'
MRTaMC                   eval      lblvl2 = 1
MRTaA*
MRTbD *                  when   **     lbaisl = ' 86'
MRTbD *                         ** and lbloc >= 100
MRTbD *                         ** and lbloc <= 103
MRTbD *                  eval   ** lblvl2 = 40
MRTaA*    backwards
MRTaAC                   when          lbaisl = ' 86'
MRTbD **                        ** and lbloc <= 106
MRTaAC                   eval      lblvl2 = 13
MRTaA*
MRTaAC                   when          lbaisl >= ' 31'
MRTaAC                             and lbaisl <= ' 32'
MRTaAC                   eval      lblvl2 = 15
MRTaA*
MRTaAC                   when          lbaisl = ' 35'
MRTaAC                   eval      lblvl2 = 16
MRTaA*
MRTaAC                   when          lbaisl >= ' 33'
MRTaAC                             and lbaisl <= ' 34'
MRTaAC                   eval      lblvl2 = 17
MRTaA*
MRTcAC                   when          lbaisl = ' 42'
MRTcAC                             and lbloc = 250
MRTcAC                   eval      lblvl2 = 24
MRTaA*
MRTcAC                   when          lbaisl = ' 84'
MRTcAC                             and lbloc = 208
MRTcAC                   eval      lblvl2 = 25
MRTaA*    backwards
MRTaAC                   when          lbaisl = ' 43'
MRTaAC                   eval      lblvl2 = 26
MRTaA*
MRTaAC                   when          lbaisl = ' 41'
MRTaAC                   eval      lblvl2 = 27
MRTaA*    backwards
MRTaAC                   when          lbaisl = ' 42'
MRTaAC                   eval      lblvl2 = 28
MRTaA*
MRTaAC                   when          lbaisl = ' 84'
MRTaAC                   eval      lblvl2 = 30
MRTaA*
MRTaAC                   when          lbaisl = ' 83'
MRTaAC                   eval      lblvl2 = 31
MRTaA*
MRTaAC                   when          lbaisl = ' 82'
MRTaAC                   eval      lblvl2 = 32
MRTaA*
MRTaAC                   when          lbaisl = ' 85'
MRTcD *                         ** and (lbloc = 100
MRTcD *                         ** or lbloc = 102)
MRTbD *                  eval   ** lblvl2 = 33
MRTbMC                   eval      lblvl2 = 14
MRTaA*    backwards
MRTaAC                   when          lbaisl = ' 81'
MRTaAC                   eval      lblvl2 = 45
MRT A*
MRT AC                   other
MRT AC                   eval      lblvl2 = 50
MRT A*
MRT AC                   endsl
MRT A
MRT A*      Then everything else.
MRT A
MRT A*        Note, by setting everything else to 50, the normal Aisle,
MRT A*        Picking Seq. order takes affect. Also, by using 50, the
MRT A*        possibility is left open to assign an aisle to be picked last
MRT A
MRT AC                   other
MRT AC                   eval      lblvl2 = 50
MRT AC                   endsl
MRT A
MRT AC     endMRTseq     endsr
MRT A*
SWT A*----------------------------------------------------------------
SWT A*  SWTseq -  Special sequencing for Southwest Traders
SWT A*----------------------------------------------------------------
SWT A
SWT AC     swtseq        begsr
SWT AC                   eval      iflag = *off
SWT A
SWT A*    Set up custom sequence for use with LABEL32D.
SWT A
SWT AC                   select
SWT A
SWT A*      When Department FRESH.
SWT AC                   when      lbwhdp = 'FRESH'
SWT AC                   eval      lblvl2 = 1
SWT A*
SWT A*      When Department DRY.
SWT AC                   when      lbwhdp = 'DRY'
SWTaDC***                eval      lblvl2 = 2
SWTaAC                   select
SWTaAC                   when      lbaisl < '071'
SWTaAC                   eval      lblvl2 = 2
SWTaA*
SWTaAC                   when      lbaisl = '071'
SWTaAC                             and lbloc < 700
SWTaAC                   eval      lblvl2 = 2
SWTaA*
SWTaAC                   when      lbaisl = '071'
SWTaAC                             and lbloc > 699
SWTaAC                             and lbloc < 800
SWTbD **                           and lbrlvl = 10
SWTbMC                             and lbrlvl <= 10
SWTaAC                   eval      lblvl2 = 3
SWTaA*
SWTaAC                   when      lbaisl = '071'
SWTaAC                             and lbloc > 699
SWTaAC                             and lbloc < 800
SWTaAC                             and lbrlvl > 10
SWTaAC                   eval      lblvl2 = 4
SWT A*
SWTaAC                   when      lbaisl = '071'
SWTaAC                             and lbloc > 799
SWTaAC                   eval      lblvl2 = 5
SWTaA*
SWTaAC                   when      lbaisl > '071'
SWTaAC                   eval      lblvl2 = 6
SWTaAC                   endsl
SWTaA*
SWT A*      Then everything else.
SWT A
SWT A*        Note, by setting everything else to 50, the normal Aisle,
SWT A*        Picking Seq. order takes affect. Also, by using 50, the
SWT A*        possibility is left open to assign an aisle to be picked last
SWT A
SWT AC                   other
SWT AC                   eval      lblvl2 = 50
SWT AC                   endsl
SWT A
SWT AC     endSWTseq     endsr
SWT A*
YHA A*----------------------------------------------------------------
YHA A*  YHataSeq -  Special sequencing for Y.Hata - Oahu
YHA A*----------------------------------------------------------------
YHA A
YHA AC     YHataSeq      begsr
YHA AC                   eval      iflag = *off
YHA A
YHA A*    Only update type 'O' labels.
YHA A
YHA AC                   if        lbtype <> 'O'
YHA AC                   eval      iflag = *on
YHA AC                   goto      endYHata
YHA AC                   endif
YHA A
YHA A*    Retrieve corresponding SLOT2 record for aisle xx.
YHA A*    When slot Side is needed.
YHA A
YHA AC**                 if        lbaisl = ' xx'
YHA AC**   keysl2        chain     slot2
YHA AC**                 if        not %found
YHA AC**                 eval      slside = 0
YHA AC**                 endif
YHA AC**                 endif
YHA A
YHA A*    Set up custom sequence for use with LABEL32C.
YHA A
YHA AC                   select
YHA A
YHA A*      Pick dept CHL.
YHA A
YHA AC                   when      lbwhdp = 'CHL'
YHA A
YHA AC                   select
YHA AC                   when      lbaisl = ' 24'
YHA AC                   eval      lblvl2 = 1
YHA A*
YHA AC                   when      lbaisl = ' 25'
YHA AC                   eval      lblvl2 = 5
YHA A*
YHA AC                   other
YHA AC                   eval      lblvl2 = 50
YHA AC                   endsl
YHA A
YHA A*
YHA A*      Then everything else.
YHA A
YHA A*        Note, by setting everything else to 50, the normal Aisle,
YHA A*        Picking Seq. order takes affect. Also, by using 50, the
YHA A*        possibility is left open to assign an aisle to be picked last
YHA A
YHA AC                   other
YHA AC                   eval      lblvl2 = 50
YHA A
YHA AC                   endsl
YHA A
YHA AC     endYHata      endsr
YHA A*
510fA*----------------------------------------------------------------
510fA*  tpcseq  -  Special sequencing for TPC
510fA*----------------------------------------------------------------
510fA
510fAC     tpcseq        begsr
     C                   eval      iflag = *off

TPCfD**   Retrieve corresponding SLOT2 record for aisle 07 (zero seven)

TPCfDC**                 if        lbaisl = ' 07'
TPCfDC**   keysl2        chain     slot2
TPCfDC**                 if        not %found
TPCfDC**                 eval      slside = 0
TPCfDC**                 endif
TPCfDC**                 endif

TPCfM**   Only update type 'O' labels.

TPCfDC**                 if        (lbwhdp <> 'DRY'
TPCfDC**                           and lbwhdp <> 'REF')
TPCfDC**                           or lbtype <> 'O'
TPCfAC                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endtpc
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

TPCfD**     Pick aisle 04 (zero four) is first

TPCfDC**                 when      lbaisl = ' 04'
TPCfDC**                 eval      lblvl2 = 1

TPCfD**     Pick dept DRY
TPCfD **
TPCfDC**                 when      lbwhdp = 'DRY'
TPCfDC**                           and lbaisl = ' 01'
TPCfD**       Pick aisle 01 Last.
TPCfDC**                 eval      lblvl2 = 82
TPCfDC**                 eval      lblvl2 = 84

TPCfD**     Pick dept REF
TPCfD **
TPCfDC**                 when      lbwhdp = 'REF'
TPCfDC**                           and lbaisl <> 'XDK'
TPCfDC**                 eval      lblvl2 = 2

TPCfD**     Aisle 07 (zero seven), locations 101 - 133 Odd

TPCfDC**                 when      lbaisl = ' 07'
TPCfDC**                           and slside = 1
TPCfDC**                           and slloc >= 101
TPCfDC**                           and slloc <= 133
TPCfDC**                 eval      lblvl2 = 3
TPCfDC**                 eval      lblvl2 = 2

TPCfDC**                 when      lbaisl = ' 80'
TPCfDC**                 eval      lblvl2 = 83

TPCfDC**                 when      lbaisl = ' 71'
TPCfDC**                           and lbloc >= 218
TPCfDC**                           and lbloc <= 233
TPCfDC**                           and lbloc >= 214
TPCfDC**                           and lbloc >= 210
TPCfDC**                           and lbloc <= 241
TPCfDC**                 eval      lblvl2 = 82

TPCfDC**                 when      lbaisl = ' 79'
TPCfDC**                 eval      lblvl2 = 81

TPCfAC                   when      lbwhdp = 'REF'
TPCfAC                             and lbaisl >= ' 20'
TPChDC*                            and lbaisl <= ' 39'
TPChMC                             and lbaisl <= ' 22'
TPCfAC                   eval      lblvl2 = 5
TPChMC                   eval      lblvl2 = 1

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl  = ' 23'
TPChAC                   eval      lblvl2 = 2

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl >= ' 24'
TPChAC                             and lbaisl <= ' 26'
TPChAC                   eval      lblvl2 = 3

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl  = ' 27'
TPChAC                   eval      lblvl2 = 4

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl >= ' 28'
TPChAC                             and lbaisl <= ' 31'
TPChAC                   eval      lblvl2 = 5

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl  = ' 32'
TPChAC                   eval      lblvl2 = 6

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl >= ' 33'
TPChAC                             and lbaisl <= ' 34'
TPChAC                   eval      lblvl2 = 7

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl  = ' 35'
TPChAC                   eval      lblvl2 = 8

TPChAC                   when      lbwhdp = 'REF'
TPChAC                             and lbaisl >= ' 36'
TPChAC                             and lbaisl <= ' 39'
TPChAC                   eval      lblvl2 = 9

TPCfAC                   when      lbwhdp = 'FRZ'
TPCfAC                             and lbaisl >= ' 40'
TPCfAC                             and lbaisl <= ' 49'
TPCfAC                   eval      lblvl2 = 10

TPCfAC                   when      lbwhdp = 'DRY'
TPCfAC                             and lbaisl >= ' 04'
TPCfAC                             and lbaisl <= ' 09'
TPCfAC                   eval      lblvl2 = 15

TPCfAC                   when      lbwhdp = 'DRY'
TPCfAC                             and lbaisl = ' 01'
TPCfAC                   eval      lblvl2 = 20

TPCgDC**                 when         (lbwhdp = 'DRY'
TPCgDC**                           and lbaisl = ' 70')
TPCgDC**                           or (lbwhdp = 'DRY'
TPCgDC**                           and lbaisl = ' 71'
TPCgDC**                           and lbloc  < 210)
TPCgDC**                           or (lbwhdp = 'DRY'
TPCgDC**                           and lbaisl = ' 71'
TPCgDC**                           and lbloc  > 241)
TPCgDC**                           or (lbwhdp = 'DRY'
TPCgDC**                           and lbaisl >= ' 72'
TPCgDC**                           and lbaisl <= ' 76')
TPCgAC                   when      lbwhdp = 'DRY'
TPCgAC                             and lbaisl >= ' 70'
TPCgAC                             and lbaisl <= ' 79'
TPCfAC                   eval      lblvl2 = 25

TPCfAC                   when      lbwhdp = 'REF'
TPCfAC                             and lbaisl >= ' 50'
TPCfAC                             and lbaisl <= ' 59'
TPCfAC                   eval      lblvl2 = 30

TPCgDC**                 when      lbwhdp = 'DRY'
TPCgDC**                           and lbaisl = ' 81'
TPCgDC**                 eval      lblvl2 = 35

TPCgDC**                 when      lbwhdp = 'DRY'
TPCgDC**                           and lbaisl = ' 71'
TPCgDC**                           and lbloc >= 210
TPCgDC**                           and lbloc <= 241
TPCgDC**                 eval      lblvl2 = 40

TPCgDC**                 when      lbwhdp = 'DRY'
TPCgDC**                           and lbaisl = ' 80'
TPCgDC**                 eval      lblvl2 = 45

TPCfAC                   when      lbwhdp = 'REF'
TPCfAC                             and lbaisl = ' 60'
TPCfAC                   eval      lblvl2 = 50

     *      Then everything else.

     *        Note, by setting everything else to 80, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 80, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 80

     C                   endsl

     C     endtpc        endsr
EFCaA*----------------------------------------------------------------
    A*  efcseq  -  Special sequencing for Eastland
     *----------------------------------------------------------------

     C     efcseq        begsr
     C                   eval      iflag = *off

     **   Only update department REF

     C                   if        lbwhdp <> 'GEN'
     C                   eval      iflag = *on
     C                   goto      endefc
     C                   endif

     **   Only update "O" type labels

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endefc
     C                   endif


     C     keyitem       chain     piritem
     C                   if        %found(piritem)
EFCbAC                   select
     C                   when      itdesg = 'RICE'
EFCbAC                             and lwswgt > 250
     C                   eval      lblvl2 = 10
EFCbAC                   when      lwswgt >= ophvy
EFCbAC                             and lwqalc > 1
EFCbAC                   eval      lblvl2 = 15
     C                   other
     C                   eval      lblvl2 = 50
EFCbAC                   endsl
     C                   endif

     C     endefc        endsr
730aA
730aA*----------------------------------------------------------------
730aA*  softCode  -  Use files DFPICKPSQ and DFPICKDTL to determine
730aA*               pick label order
730aA*----------------------------------------------------------------
730aA
730aAC     softCode      begsr
730aA*
730aA*  When reaching this routine it has been determined the customer
730aA*  uses USER defined definitions for determining the processing order
730aA*  instead of the hard coded routine that was used.  That process still
730aA*  exists in routine originalMain routine.  However, when reaching this
730aA*  routine it will not execute the manual routine
730aA*
730aA /free
730aA     // First setup and retrieve proper lvl2 value
730aA        lblvl2=99;
730aA        sqlstmtl = 'Select * from dfpickdtl as d where ' +
730aA                  'dfdwhse = ' + %char(lbwhse);
730aA
730aA        // add Warehouse Department if exists
730aA        if lbwhdp <> *blanks;
730aA           sqlstmtl= %trim(sqlStmtl) + ' and (dfdwhdp=' +
730aA                     sq + %trim(lbwhdp) + sq +
730bA                     ' or dfdwhdp=' + sq + ' ' + sq + ')';
730aA        endif;
730aA
730aA        // add Section Type if exists
730aA        if lbstyp <> *blanks;
730aA           sqlstmtl= %trim(sqlStmtl) + ' and (dfdstyp=' +
730aA                     sq + %trim(lbstyp) + sq +
730bA                     ' or dfdstyp=' + sq + ' ' + sq + ')';
730aA        endif;
730aA
730aA        // add Label Type if exists
730aA        if lbtype <> *blanks;
730aA           sqlstmtl= %trim(sqlStmtl) + ' and (dfdltype=' +
730aA                     sq + %trim(lbtype) + sq +
730bA                     ' or dfdltype=' + sq + ' ' + sq + ')';
730aA        endif;
730aA
730aA        // add Designation check.  Either select from dfdpickdtl if
             // Designation is blank or we find a match in the item master
730aA        sqlstmtl= %trim(sqlStmtl) + ' and (dfddesg=' +
730aA                  sq + ' ' + sq + ' or (select count(*) ' +
730bA                  ' from piritem as p where itwhse=' + %char(lbwhse) +
                       ' and ititem=' + sq + %trim(lbitem) + sq + ' and ' +
                       'itwhdp=' + sq + %trim(lbwhdp) + sq + ' and ' +
                       'p.itdesg=d.dfddesg)<>0)';
730aA
730aA        // add Activity Code check.  Either select from dfdpickdtl if
             // Activity is blank or we find a match in the item master
730aA        sqlstmtl= %trim(sqlStmtl) + ' and (dfdactv=' +
730aA                  sq + ' ' + sq + ' or (select count(*) ' +
730bA                  ' from piritem as ai where itwhse=' + %char(lbwhse) +
                       ' and ititem=' + sq + %trim(lbitem) + sq + ' and ' +
                       'itwhdp=' + sq + %trim(lbwhdp) + sq + ' and ' +
                       'ai.itactv=d.dfdactv)<>0)';
730aA
730aA        // add Build Code check.  Either select from dfdpickdtl if
             // Build Code is blank or we find a match in the item master
730aA        sqlstmtl= %trim(sqlStmtl) + ' and (dfdbld=' +
730aA                  sq + ' ' + sq + ' or (select count(*) ' +
730bA                  ' from piritem as bi where itwhse=' + %char(lbwhse) +
                       ' and ititem=' + sq + %trim(lbitem) + sq + ' and ' +
                       'itwhdp=' + sq + %trim(lbwhdp) + sq + ' and ' +
                       'bi.itbld=d.dfdbld)<>0)';
730aA
730aA        // add Category check.  Either select from dfdpickdtl if
             // Category Code is blank or we find a match in the itemfld
730aA        sqlstmtl= %trim(sqlStmtl) + ' and (dfdcat=' +
730aA                  sq + ' ' + sq + ' or (select count(*) ' +
730bA                  ' from itemfld as f where ifwhse=' + %char(lbwhse) +
                       ' and ifitem=' + sq + %trim(lbitem) + sq + ' and ' +
                       'f.ifcat=d.dfdcat)<>0)';
730aA
730aA        // add Item Class check.  Either select from dfdpickdtl if
             // Item Class Code is blank or we find a match in the itemfld
730aA        sqlstmtl= %trim(sqlStmtl) + ' and (dfdclcde=' +
730aA                  sq + ' ' + sq + ' or (select count(*) ' +
730bA                  ' from itemcls as ic where iclwhs=' + %char(lbwhse) +
                       ' and iclitm=' + sq + %trim(lbitem) + sq + ' and ' +
                       'ic.iclcde=d.dfdclcde)<>0)';
730bA
730bA        // add Item Weight range if exists
730bA        if lbuwgt<>*zeros;
730bA
730bA           // Add Item weight conditios
730bA           // Perform 4 conditions to determine if match.
730bA           // 1) if LBUWGT equals from Item Weight
730bA           // 2) if from Weight(dfduwgt1) is blank and to Weight(dfduwgt2)>=LBUWGT
730bA           // 3) if From Weight(dfduwgt1 <= LBUWGT and To Weight(dfduwgt2)>=LBUWGT
730bA           // 4) if both from Weight(dfduwgt1) and to Weight(dfduwgt2) are blank
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((dfduwgt1=' +
730bA                     %char(lbuwgt) + ' and dfduwgt2=0' +
730bA                     ') or (dfduwgt1=0' + ' and dfduwgt2>=' +
730bA                     %char(lbuwgt) + ') or (dfduwgt1<=' + %char(lbuwgt)
730bA                     + ' and dfduwgt2>=' + %char(lbuwgt) +
730bA                     ') or (dfduwgt1=0 and dfduwgt2=0))';
730aA        endif;
730bA
730bA        // add Label Weight range if exists
730bA        if lbswgt<>*zeros;
730bA
730bA           // Add Label weight conditios
730bA           // Perform 4 conditions to determine if match.
730bA           // 1) if LBSWGT equals from Label Weight
730bA           // 2) if from Weight(dfdswgt1) is blank and to Weight(dfdswgt2)>=LBSWGT
730bA           // 3) if From Weight(dfduwgt1 <= LBUWGT and To Weight(dfduwgt2)>=LBUWGT
730bA           // 4) if both from Weight(dfdswgt1) and to Weight(dfdswgt2) are blank
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((dfdswgt1=' +
730bA                     %char(lbswgt) + ' and dfdswgt2=0' +
730bA                     ') or (dfdswgt1=0' + ' and dfdswgt2>=' +
730bA                     %char(lbswgt) + ') or (dfdswgt1<=' + %char(lbswgt)
730bA                     + ' and dfdswgt2>=' + %char(lbswgt) +
730bA                     ') or (dfdswgt1=0 and dfdswgt2=0))';
730aA        endif;
730aA
730bA        // add UOM Type selection
730bA        if lbutyp<>*blanks;
730bA
730bA           // Add UOM type conditions
730bA           // Perform 3 conditions to determine if match.
730bA           // 1) if LBUTYP equals Case('N') and dfdutyp in(' ','N')  (Any or Case)
730bA           // 2) if LBUTYP equals Case('1') and dfdutyp in(' ','1')  (Any or Brk1)
730bA           // 3) if LBUTYP equals Case('2') and dfdutyp in(' ','2')  (Any or Brk2)
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((' + sq + lbutyp + sq +
730bA                     '=' + sq + 'N' + sq + ' and dfdutyp in(' + sq + ' ' +
730bA                     sq + ',' + sq + 'N' + sq + ')) or ' +
730aA                     '(' + sq + lbutyp + sq +
730bA                     '=' + sq + '1' + sq + ' and dfdutyp in(' + sq + ' ' +
730bA                     sq + ',' + sq + '1' + sq + ')) or ' +
730aA                     '(' + sq + lbutyp + sq +
730bA                     '=' + sq + '2' + sq + ' and dfdutyp in(' + sq + ' ' +
730bA                     sq + ',' + sq + '2' + sq + ')))';
730bA        endif;
730aA
730aA        // add Aisle condition if exists
730aA        // when Aisle 2 present then use range between 1 and 2
730aA        if lbaisl<>*blanks;
730aA
730bA           // Add Aisle conditions
730bA           // Perform 4 conditions to determine if match.  These 4 or are used
730bA           //         on all range values
730bA           // 1) if LBAISL equals from Aisle
730bA           // 2) if from Aisle(dfdaisl1) is blank and to Aisle(dfdaisl2)>=LBAISL
730bA           // 3) if From Aisle(dfdaisl1 <= LBAISL and To Aisle(dfdaisl2)>=LBAISL
730bA           // 4) if both from Aisle(dfdaisl1) and to Aisle(dfdaisl2) are blank
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((dfdaisl1=' +
730bA                     sq + lbaisl + sq + ' and dfdaisl2=' + sq + ' ' + sq +
730bA                     ') or (dfdaisl1=' + sq + ' ' + sq + ' and dfdaisl2>='
730bA                     + sq + lbaisl + sq + ') or (dfdaisl1<=' + sq +
730bA                     lbaisl + sq + ' and dfdaisl2>=' + sq + lbaisl + sq +
730bA                     ') or (dfdaisl1=' + sq + ' ' + sq + ' and ' +
730bA                     'dfdaisl2=' + sq + ' ' + sq + '))';
730aA        endif;
730aA
730bA        // add Item Number range if exists
730bA        if lbitem<>*blanks;
730bA
730bA           // Add Item conditions
730bA           // Perform 4 conditions to determine if match.  These 4 or are used
730bA           //         on all range values
730bA           // 1) if LBITEM equals from Item
730bA           // 2) if from Item(dfditem1) is blank and to Item(dfditem2)>=LBITEM
730bA           // 3) if From Item(dfditem1 <= LBITEM and To Item(dfditem2)>=LBITEM
730bA           // 4) if both from Item(dfditem1) and to Item(dfditem2) are blank
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((dfditem1=' +
730bA                     sq + %trim(lbitem) + sq + ' and dfditem2=' + sq + ' '
730bA                     + sq + ') or (dfditem1=' + sq + ' ' + sq + ' and' +
730bA                     ' dfditem2>=' + sq + %trim(lbitem) + sq + ') or' +
730bA                     '(dfditem1<=' + sq + %trim(lbitem) + sq +
730bA                     ' and dfditem2>=' + sq + %trim(lbitem) + sq +
730bA                     ') or (dfditem1=' + sq + ' ' + sq + ' and ' +
730bA                     'dfditem2=' + sq + ' ' + sq + '))';
730aA        endif;
730bA
730bA        // add Location Number range if exists
730bA        if lbloc<>*zeros;
730bA
730bA           // Add Location conditions
730bA           // Perform 4 conditions to determine if match.  These 4 or are used
730bA           //         on all range values
730bA           // 1) if LBLOC equals from Location
730bA           // 2) if from Location(dfdloc1) is blank and to Location(dfdloc2)>=LBLOC
730bA           // 3) if From Location(dfdloc1 <= LBLOC and To Location(dfdloc2)>=LBLOC
730bA           // 4) if both from Location(dfdloc1) and to Location(dfdloc2) are blank
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((dfdloc1=' +
730bA                     %char(lbloc) + ' and dfdloc2=0' +
730bA                     ') or (dfdloc1=0' + ' and dfdloc2>=' +
730bA                     %char(lbloc) + ') or (dfdloc1<=' + %char(lbloc)
730bA                     + ' and dfdloc2>=' + %char(lbloc) +
730bA                     ') or (dfdloc1=0 and dfdloc2=0))';
730aA        endif;
730bA
730bA        // add Level Number range if exists
730bA        if lbrlvl<>*zeros;
730bA
730bA           // Add Level conditions
730bA           // Perform 4 conditions to determine if match.  These 4 or are used
730bA           //         on all range values
730bA           // 1) if LBRLVL equals from Level
730bA           // 2) if from Level(dfdrlvl1) is blank and to Level(dfdrlvl2)>=LBRLVL
730bA           // 3) if From Level(dfdrlvl1 <= LBRLVL and To Level(dfdrlvl2)>=LBRLVL
730bA           // 4) if both from Level(dfdrlvl1) and to Level(dfdrlvl2) are blank
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((dfdrlvl1=' +
730bA                     %char(lbrlvl) + ' and dfdrlvl2=0' +
730bA                     ') or (dfdrlvl1=0' + ' and dfdrlvl2>=' +
730bA                     %char(lbrlvl) + ') or (dfdrlvl1<=' + %char(lbrlvl)
730bA                     + ' and dfdrlvl2>=' + %char(lbrlvl) +
730bA                     ') or (dfdrlvl1=0 and dfdrlvl2=0))';
730aA        endif;
730aA
730bA        // add Slot Handstack range if exists
730bA        if lbhand<>*blanks;
730bA
730bA           // Add Slot Handstack conditions
730bA           // Perform 4 conditions to determine if match.  These 4 or are used
730bA           //         on all range values
730bA           // 1) if LBHAND equals from Item
730bA           // 2) if from Handstack(dfdhnd1) is blank and to Handstack(dfdhnd2)>=LBHAND
730bA           // 3) if From Handstack(dfdhnd1= LBHAND and To Item(dfdhnd2)>=LBHAND
730bA           // 4) if both from Handstack(dfdhnd1) and to Handstack(dfdhnd2) are blank
730aA           sqlstmtl = %trim(sqlStmtl) + ' and ((dfdhnd1=' +
730bA                     sq + %trim(lbhand) + sq + ' and dfdhnd2=' + sq + ' '
730bA                     + sq + ') or (dfdhnd1=' + sq + ' ' + sq + ' and' +
730bA                     ' dfdhnd2>=' + sq + %trim(lbhand) + sq + ') or' +
730bA                     '(dfdhnd1<=' + sq + %trim(lbhand) + sq +
730bA                     ' and dfdhnd2>=' + sq + %trim(lbhand) + sq +
730bA                     ') or (dfdhnd1=' + sq + ' ' + sq + ' and ' +
730bA                     'dfdhnd2=' + sq + ' ' + sq + '))';
730bA        endif;
730bA
730bA        // Odd or Even locations
730bA        // Uses SQL MOD to determine if even and case statement to
730bA        // compare place either "E" or "O" in clause.  If not found
730bA        // then uses blank
730bA        sqlStmtl = %trim(sqlStmtl) + ' and (dfdside=(case ' +
730bA                  'when MOD('+ %char(LBLOC) + ',2)=0 then ' + sq + 'E' +
730bA                  sq + ' else ' + sq + 'O' + sq + ' end) or (dfdside=' +
730bA                  sq + ' ' + sq +'))';
730aA
730aA        // add Slot Zone condition
             // Slot Zone is blank or we find a match in the WORKLBL
             // ALWAYS look for Slot Zone in WORKLBL, never LABEL
730aA        sqlstmtl= %trim(sqlStmtl) + ' and (dfdszon=' +
730aA                  sq + ' ' + sq + ' or (select count(*) ' +
730bA                  ' from worklbl as wl where lwlbl#=' + %char(lblbl#) +
                       ' and wl.lwszon=d.dfdszon)<>0)';
730bA
730bA        // Add sort Ascending to get highest ranked selection
730bA        sqlStmtl = %trim(sqlStmtl) + ' order by dfdcmpprty,dfdlvl2';
730bA
730aA        exec sql PREPARE dd FROM :SqlStmtl;
730aA        exec sql DECLARE ddsql SCROLL CURSOR FOR dd;
730aA        exec sql OPEN ddsql;
730aA
730aA        exec sql fetch first from ddsql into :dfdrec;
730aA        if sqlStt = sqlSuccess;
730aA           lblvl2 = dfdlvl2;
730aA           if UseSingleLabel;
730bA              $ids=%char(dfdid);
730bA           endif;
730aA        endif;
730bA
730bA        dow forever = forever and UseSingleLAbel;
730bA           exec sql fetch next from ddsql into :dfdrec;
730bA           if sqlStt <> sqlSuccess;
730bA              leave;
730bA           endif;
730bA           $ids = %trim($ids) + ' ' + %char(dfdid);
730bA        enddo;
730aA        exec sql close ddsql;
730aA
730aA /end-free
730aAC                   endsr
730aA
SGCaA*----------------------------------------------------------------
SGCaA*  SGCseq     -  Special sequencing for Springfield Grocer
SGCaA*----------------------------------------------------------------
SGCaA
SGCaAC     sgcseq        begsr
     C                   eval      iflag = *off

     **   Only update department DRY

     C                   if        lbwhdp <> 'DRY'
     C                   eval      iflag = *on
     C                   goto      endsgc
     C                   endif

     **   Only update "O" type labels

     C                   if        lbtype <> 'O'
     C                   eval      iflag = *on
     C                   goto      endsgc
     C                   endif

     C                   select
     C                   when      lbwhdp = 'DRY'

     C                   select
SGCbD*      Pick aisle  XDK after aisle DK

SGCbDC*                  when      lbaisl <= ' DJ'
SGCbDC*                  eval      lblvl2 = 5

SGCdAC                   when      lbaisl = 'XDK'
SGCdA*      LBPSEQ is updated instead of LBLVL2 since SGC uses LABEL32G
SGCdA*      which does not use LBLVL2 as part of file key.
SGCdAC                   eval      lbpseq = 43

SGCcAC                   when          lbaisl = ' DC'
SGCcAC                             and lbloc  >= 200
SGCcAC                             and lbloc  <= 255
SGCcAC                             and lbrlvl >= 1
SGCcAC                             and lbrlvl <= 2
SGCcAC                   eval      lblvl2 = 5

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

     C                   other
     C                   eval      lblvl2 = 50

     C                   endsl

SGCaAC     endsgc        endsr
SGCaA
     *----------------------------------------------------------------
510iA*  *INZSR  Initialization subrotine

510iAC     *inzsr        begsr
     *
510iA*  Get item maintenance options.
     *
510iAC                   eval      ophvy  = 0
510iAC                   eval      opcode = '*ITEMMNT'
510iAC     opkey_whse    chain     options
730aA**
730aA**  Get Slot Sequence with new Option and possible soft coding
730aA**
730aAc                   eval      $pcmd = '*ISSOFT'
730cAc                   monitor
730aAc                   call      'GETPSEQO'
730aAc                   parm                    $pcmd             8
730aAc                   parm                    $pwhse
730aAc                   parm      ' '           $pwhdp            5
730aAc                   parm      ' '           $pdisp           12
730aAc                   parm      ' '           $pSeqcd           1
730aAc                   parm      0             $pSeq             5 0
730aAc                   parm      ' '           $plvl2            1
730cAc                   on-error
730cAc                   eval      $plvl2 = 'N'
730cAc                   endmon
730aA *
730aAc                   if        $plvl2 = 'Y'
730aAc                   eval      softCoded = *on
730aAc                   else
730aAc                   eval      softCoded = *off
730aAc                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
640cA*  zzzdricop  Call DRICOP
640cA*----------------------------------------------------------------
640cA
640cAC     zzzdricop     begsr
     C***                eval      error = *off

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      'DFPICK'      $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata
     C     $item2        parm      $item2        $dridata2

     C                   select

     C                   when      %error
     C***                eval      error = *on
     C***                eval      errmsg    = 'Error occured on call to '
     C***                                    + 'DRICOP'
     C***                                    + '/' + %trim($drisubcmd)
     C***                                    + ' from ' + #prog
     C***                if        zmsflag
     C***                exsr      zm0105s
     C***                else
     C***                exsr      zm0105
     C***                endif

     C                   when      $drireturn <> '*OK'
     C***                eval      error = *on
     C***                if        zmsflag
     C***                exsr      zm0001s
     C***                else
     C***                exsr      zm0001
     C***                exsr      zzerrind
     C***                endif

     C                   endsl

     C***                eval      zmsflag = *off
     C     enddricop     endsr
700BA*----------------------------------------------------------------
7OOBA*  SUBROUTINE: $Copflds (Copy fields from WORKLBL8 to be used   -
7OOBA*              like LABEL13 fields in program.....)             -
700BA*----------------------------------------------------------------
  |   /Free
  |                    BegSR $Copflds;
  |
  |                          LBWHSE = LWWHSE;
  |                          LBWHDP = LWWHDP;
  |                          LBSEQ  = LWSEQ;
  |                          LBITEM = LWITEM;
  |                          LBPBAT = LWPBAT;
  |                          LBAISL = LWAISL;
  |                          LBLOC  = LWLOC;
  |                          LBRLVL = LWRLVL;
  |                          LBHAND = LWHAND;
  |                          LBPSEQ = LWPSEQ;
  |                          LBSTYP = LWSTYP;
  |                          LBQRYF = LWQRYF;
  |                          LBDISP = LWDISP;
  |                          LBQAVL = LWQAVL;
  |                          LBWHS2 = LWWHS2;
  |                          LBWHD2 = LWWHD2;
  |                          LBASL2 = LWASL2;
  |                          LBLOC2 = LWLOC2;
  |                          LBLVL2 = LWLVL2;
  |                          LBHND2 = LWHND2;
  |                          LBDSP2 = LWDSP2;
  |                          LBRTE  = LWRTE;
  |                          LBSTOP = LWSTOP;
  |                          LBORD  = LWORD;
  |                          LBSPCL = LWSPCL;
  |                          LBPO   = LWPO;
  |                          LBUTYP = LWUTYP;
  |                          LBUCOD = LWUCOD;
  |                          LBUCUB = LWUCUB;
  |                          LBCUBE = LWCUBE;
  |                          LBUWGT = LWUWGT;
  |                          LBSWGT = LWSWGT;
  |                          LBQALC = LWQALC;
  |                          LBQRMN = LWQRMN;
  |                          LBQPCK = LWQPCK;
  |                          LBTIE  = LWTIE;
  |                          LBHIGH = LWHIGH;
  |                          LBGRP1 = LWGRP1;
  |                          LBGRP2 = LWGRP2;
  |                          LBTYPE = LWTYPE;
  |                          LBLBL# = LWLBL#;
  |                          LBPAL# = LWPAL#;
  |                          LBTRN# = LWTRN#;
  |                          LBCTR# = LWCTR#;
  |                          LBSTAT = LWSTAT;
  |                          LBPRTY = LWPRTY;
  |                          LBSDTE = LWSDTE;
  |                          LBSTIM = LWSTIM;
  |                          LBRDTE = LWRDTE;
  |                          LBVRFY = LWVRFY;
700bA                  EndSR;

