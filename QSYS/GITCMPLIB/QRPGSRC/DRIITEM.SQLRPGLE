417cA /copy *libl/qcopysrc,hspecs
417cDH*COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
417cDH*Option(*Nodebugio)

650aA*--------------------
650aA* File changes made to handle multiple parent Repacks. See Repack
650aA* notes below.
650aA*--------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *                                                   h
     *  DRIITEM   Dakota realtime interface - item maintenance
     *  28 September 2001
     *  Dave Sommerville
     *
     *      For add or change, can not update ITEMDEF records,
     *      user will need to make any changes in item maintenance.
     *
416  *    09/28/01  DAS  4.16
     *      - Created
     *
416a *    10/04/01  DAS  4.16a
     *      - Changed table DESC into TABCODE/TABDESC.
     *      - Added $pmessage parameter.
     *      - Revised to send back message text with error code.
     *      - Revised to skip whse and item checks for *OPEN/*CLOSE.
     *
416b *    10/12/01  DAS  4.16b
     *      - Revised zzdeli routine to look for *VERIFYDEL instead
     *        of *VERIFY.
     *      - Revised zzchki routine to look for *VERIFYADD and
     *        *VERIFYCHG instead of *VERIFY.
     *
416c *    12/03/01  DAS  4.16c
     *      - Revised additem routine to add extended description.
     *      - Revised change routines to only work with extended
     *        descriptions if the description is not blank.
     *
416d *    12/04/01  DAS  4.16d
     *      - Added *GETBASE, *GETSLOT, *GETSSB.
     *
416e *    01/23/02  DAS  4.16e
     *      - Revised to identify if called from Dakota.
     *      - Revised to call DRIMAIN2 to update the host when called
     *        from Dakota. This allows the Dakota program to only have
     *        to make a single call to the interface.
     *      - Revised getall routine to include ITEMMSC info when
     *        doing a *GETMAIN.
     *
416f *    04/12/02  DAS  4.16f
     *      - Revised some DakotaCall IF statements because they
     *        prevented calls from host.
     *
416g *    05/22/02  DAS  4.16g
     *      - Revised routine VERIFY to set on error flag when item
     *        is not a slot item.
     *      - Revised VERIFY routines to initialize error flag.
     *
416h *    06/28/02  DAS  4.16h
     *      - Revised routine ADDITEM to default itcwgt to 'N'.
     *
416i *    04/08/03  DAS  4.16i
     *      - Updated C#ITEM to version 2 (Added ITEMMSC fields).
     *      - Revised routines to use new fields.
     *
416j *    06/11/03  DAS  4.16j
     *      - Split C#ITEM into two data structures because of 512 limit.
     *      - Added second data parameter to program.
     *
417  *    06/11/03  DAS  4.17
     *      - Logic for field IMODAY added (already added to C#ITEM)
     *
417aA*    04/07/04  MLB  4.17a
     *      - Fix: Revised routine DELETEITEM to allow alias, contract
     *        and SSB items to be deleted even if base item has quantity.
     *
417bA*    04/21/04  DAS  4.17b
     *      - Fix: Revised routine GETSSB to use field svitem2.
     *
417cA*    05/24/04  DAS  4.17c
     *      - Enh: Change header info into /Copy.
     *      - Enh: Added *GETNXTMFG to get item for Mfg code.
     *
417dA*    07/29/04  DAS  4.17d
     *      - Fix: Revised to loop correctly in GETSLOT.
     *
417dA*    08/25/04  DAS  4.17e
     *      - Enh: Revised valid license tracking (imltrk) values from
     *        Y/N to H=High, L=Low and N=Not tracked.
     *
500 A*    11/13/04  DAS  5.00
     *      - Enh: Revised valid license tracking (imltrk) values from
     *        H,L,N to L=Low, M=Medium and H=High.
     *
500aA*    01/11/05  DAS  5.00a
     *      - Tmp: Only tracking level 'L' allowed at this time.
     *
500aA*    09/22/05  RH   5.00a
     *      - Enh: Added "client" logic.
     *
500bA*    11/03/05  DAS  5.00b
     *      - Enh: Added file ITEMFLD.
     *      - Enh: Added field IFCAT.
500cA*    01/06/06  MLB  5.00c
     *      - Enh: Revised program to delete all records for an item
     *        from files; ITEMSLS, ITEMQTY.
     *
510 A*    07/24/06  MLB  5.10
     *      - Enh: Revised program to delete record from item
     *        extension file, ITEMEXT1.
     *
510aA*    02/13/07  TLJ  5.10a
     *      - Enh: Revised program to write record to KITCOMP if a
     *        Repack Item Type.
     *
510bA*    02/23/07  DAS  5.10b
     *      - Revised to treat Repack similar to a ' ' and 'B' items.
     *      - Revised deleting of KITCOMP records to use a loop
     *        instead of a chain.
510cA*    11/28/07  MLB  5.10c
     *      - Enh: Revised program to add support for new Item Catchwgt
     *        code, S=Standard weight. This code will only be active in
     *        the receiving programs. All other programs will treat items
     *        with this new code just like non-catchwgt items.
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - 500a added from Jordano's code.
     *
600aA*    06/01/08  DAS  6.00  P#00045
     *      - Revised to allow 'H' and 'M' tracking.
     *
600bA*    05/19/09  DAS  6.00b
     *      - Revised GETBASE to handle base item correctly.
     *
610aA*    08/17/10  DAS  6.10a
     *      - Added field ifODRSlot for Repack items.
     *
610bA*    10/04/10  DAS  6.10b
     *      - Converted to SQL.
     *      - Revised all ITEMFLD I/O to be handled using SQL.
     *        Re: To allow the program to work with different versions
     *        of the ITEMFLD file.
     *
640 A*    09/19/11  MLB  6.40
     *      - Enh: Revised pgm to set all slots to Zero status when
     *        deleting an item.  Then DRISLOT will be called to verify
     *        slot, making the slot available for a new item.
     *      - Added file, SLOT3 to pgm.
     *      - Created c#file13 /copy src mbr for slot3.
     *
640aA*    10/21/11  DAS  6.40a
     *      - Revised to use DRIMAIN2 instead of DRIMAIN3 because
     *        DRISLOT uses DRIMAIN3 and we want to prevent a
     *        recursive call.
     *
640bA*    12/16/11  RTR  6.40b
     *      - Fix: Added test for ITCUBE size and return msg instead
     *        of error.
     *
640cA*    09/12/12  RH   6.40c Added 5.20a mod from 11/11/08
     *       - Fix: Change GETALL to stop reading ITEMDEF after 5 read
     *         was reading 6 times and causing error in array.
640dA*    09/18/12  LMC  6.40d
     *      - Added field ifucicde,ifrcvmth,ifsltmth,ifbrdflg.
     *      - Fixed Invalid lot code - message not displaying correct.
640eA*    11/12/12  LMC  6.40e
     *      - Don't allow blank values in fields
     *      ifucicde,ifrcvmth,ifsltmth,ifbrdflg.
640fA*    11/13/12  LMC  6.40f
     *      - Enh - Dependant items for an SSB item are not updated
     *      when the base item for the ssb item is updated.
     *      - Fix - INVLDSE2 rule had changed, code was not corrected.
640gA*    11/14/12  MLB  6.40g
     *      - Fix: Revised program to call all VFYxxxxxxx pgms that open
     *        a file with *CLOSE parm so that all open files are closed
     *        on exit. Y.Hata now supports 2 BFC whses using separate
     *        data files libraries and needs to have all files closed
     *        when switching divisions.
     *
650aA*    02/20/13  KDE  6.50a
     *      - Enh - add code to read User Space array created by
    *        IT112/IT116 to create/maintain KIT Component structure
     *        for Repack Items.  This also requires User Space API
     *        calls (placed after *entry)
     *      - Enh - KITITEM was added.  This file now contains the
     *        (output) information for Repack items while
     *        KITCOMP (input) contains component item information
     *      - Routines affected: AddItem, AddChild, Changeitem
     *        Changechild, Getall, and Getitem, Deleteitem
     *      - Changed routine GETITEMFLD to retrieve Repack Pick
     *        Slot from KITITEM instead of ITEMFLD
     *
650bA*    04/23/13  KDE  6.50b
     *      - Enh - add command *GETPARENT.  This command will allow
    *        item information to be returned per a parent without
     *        loading the KIT array for repack items.  We have changed
     *        the process to allow a repack item to include a repack item
     *        as one of it's parent items
     *
650cA*    06/06/13  KDE  6.50c
     *      - Enh - allow on-demand item defined on an on-demand item
     *
650dA*    07/22/13  LMC  6.50d
     *      - Enh - PTI selection not allowed on catch weight item.
     *
650eA*    08/27/13  KDE  6.50e
     *      - Fix - Allow for multiple Itemlnk records for Repack Item
     *
650fA*    10/31/13  LMC  6.50f
     *      - Enh - PTI selection not allowed with UCI receiving.
     *
650gA*    01/25/14  KDE  6.50g
     *      - Fix - Move KIT Loop in Changeitem routine.  It was
     *        only executing certain item updates when either type
     *        was 'R' or 'B'
     *
650hA*    07/22/14  JCJ/RH 6.50h
     *      - Fix - initialize ITMFLD to 1.
     *
650iA*    07/25/14  RTR   6.50i
     *      - Enh - When tracking level (imltrk) changed to M or H,
     *        call program to look for multiple licenses in slots and
     *        move them to virtuals of the same slot, reverse fifo.
     *
650i *    09/17/14  GJA  6.50i
     *      - Enh - Allow "C" custom processing for bulk pick
650kA*    01/05/15  MLB  6.50k
     *      - Fix - Correction to 6.50e mod. Correct substring error
     *        when nxtitm field <= 0 in routine updMiscItem.
700aA*    06/11/16  DAS  7.00a
     *      - Enh - Revised to delete *EACH records from
     *        ITEMAVG, ITEMSLS.
700bA*    06/24/16  LMC  7.00b
     *      - Modification for Uci Tracking. RESERVED
700cA*    10/04/16  LMC  7.00c
     *      - Modified UCI edits to be table driven.
     *      - Will use UI900 with *VERIFYB.
     *      - This allows us to add additional codes easily.
     *   **** NOTE NOTE NOTE NOTE NOTE NOTE ****
     *      If installing mod 700c you must also take along IT112 mod
     *      720c. You will also need one new file GLOUCICD which lives
     *      in BFCGLOBALF on dev.
700dA*    10/17/16  LMC  7.00d
     *      - Do not allow deletion of the branded item with it114
     *      - If the item is setup in ITEMBRD. Branded item has the
     *      - suffix added to the base item#.
710aA*    02/23/17  LMC  7.10a
     *      - Additional Edit added for the UPC changes in 700c.
     *      - When setting the uci selection method to 4 or 5 we
     *        will validate that the upc's have been collected before
     *        we allow them to turn these settings on.
710bA*    05/26/17  KDE  7.10b
     *      - Fix - Modified to create user space when called
     *        from somewhere other than Item Maintenance.  It
     *        was failing for types "B" and "R".
710cA*    04/03/17  LMC  7.10c
     *      - Additional Edit to not allow uci selection code 5 if
     *        the item is not sold as a breakdown.
720aA*    05/10/18  LMC  7.20a
     *      - Additional logic when checking items that have ssb item
     *        linked.
     *
720bA*    10/02/18  LMC  7.20b
     *      - Added edits on new standard receiving with printing of
     *        box labels to only allow ifrcvmth = 5 or 6 if the item
     *        is defined as either being sold by Breakdown 1 qty, has
     *        associated Breakdown item(type 'B') or has an associated
     *        Same Slot Breakdown item(type 'S').
     *
720cA*    06/24/16  LMC  7.20c
     *      - Modification for Uci Tracking.
     *
720dA*    01/03/19  LMC  7.20d
     *      - Reserved for gui repack changes
     *
740aA*    01/22/20  LMC  7.40a
     *      - Added logic for new selecton method 6 - upc verification
     *        Normal UOM only
740bA*    01/30/20  LMC  7.40b
     *      - Do not allow selection method 5 for an item with NO
     *        breakdown.
740cA*    10/19/20  LMC  7.40c
     *      - GUI - load repack work file.
     *      - GUI - repack edits.
     *----------------------------------------------------------------
     * Custom Mods: Vigo Importing
VGOaA*    09/22/05  RH   VGOa
     *      - FIX: Will NOT set date sensitive to 'Y' if manufacture = 'Y'
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco
     *
GRCaA*    10/02/18  KDE  GRCa
     *      - Revised pgm to Generate a Virtual Pick Slot for any
     *        On-Demand Repack Item without one.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earls
     *
EOPaA*    10/11/18  KDE  EOPa
     *      - Revised pgm to Generate a Virtual Pick Slot for any
     *        On-Demand Repack Item without one.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foodservice
     *
GFCaA*    10/07/11  RBD  GFCa
     *      - Use new cmd %SETFIFOG to call DRISLOT to calculate and
     *        update expiration date in all slots and licenses that
     *        an item occupies if mfg shelf life days (IMMDAY) is
     *        changed on a mfg dated item (IMMFLG=Y).
     *      - Use new cmd %ZEROEXPD to call DRISLOT to zero the
     *        expiration date in all slots & licenses for this item
     *        if the item is changed from ITFLGD=Y to N, indicating
     *        the item is no longer date sensitive.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP
     *
VIPaA*    04/16/19  RBD  VIPa like GFCa
     *      - Use new cmd %ZEROEXPD to call DRISLOT to zero the
     *        expiration date in all slots & licenses for this item
     *        if the item is changed from ITFLGD=Y to N, indicating
     *        the item is no longer date sensitive.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBIaA*    09/22/15  MLB  CBIa
     *      - Revised pgm to allow zero for Distributor Days and End
     *        User Days when Mfr Dated Item = Y=Yes.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D
     *
ADFaA*    05/12/17  LMC  ADFa
     *      - Revised pgm to not allow client to use UCI Receiving.
     *        This client uses Item license plates, and they are not
     *        generated until the end of the receiving process. UCI
     *        receiving requires the client to designate the license
     *        the UCI's are being received on at the beginning of the
     *        receiving process, so we can attatch them to the UCI in
     *        the uciinfo file.
ADFbA*    05/12/17  LMC  ADFb
     *      - Revised pgm to not allow client to use UCI Tracking.
     *        This client uses Item license plates, and they are not
     *        generated until the end of the receiving process. UCI
     *        Tracking requires the client uses UCI Receiving, but we
     *        don't allow them to use UCI receiving either.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit Foods
     *
MRTaA*    09/20/18  KDE  MRTa
     *      - Revised pgm to Generate a Virtual Pick Slot for any
     *        On-Demand Repack Item without one.
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
700cA*  - If installing mod 700c you must also take along IT112 mod
     *      720c. You will also need one new file GLOUCICD which lives
     *      in BFCGLOBALF on dev.
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program was based on program II235.
     *
     *----------------------------------------------------------------

650aA*----------------------------------------------------------------
650aA*  Repack Changes 6.50
650aA*  These changes allow for multiple parent items to be associated
650aA*  with a Repack Item.  As part of this change several file
650aA*  changes and additions were performed.  You can find file
650aA*  changes below but you can also refer to a more complete
650aA*  upgrade document on the Intranet under shared documents, then
650aA*  Repack, then document Repack 650 Upgrade.
650aA*
650aA*  Field KCDISP was added to KITCOMP
650aA*  Field IFODRSLOT is no longer maintained but still exists
650aA*      in file ITEMFLD
650aA*  File KITITEM was added
650aA*  Primary key was changed for file ITEMLNK
650aA*
      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *ADD              Add item and tie/high definitions.
      *
      *      *BATADD           Batch add.
      *                        Add item and tie/high definitions.
      *                        If item exists, treat as '*BATCHANGE'.
      *                        Some codes are created if they don't exist.
      *
      *      *BATCHANGE        Batch change.
      *                        Updates item and replace tie/hi defs if sent
      *                        If item does not exist, treat as '*BATADD'.
      *                        If tie/high defs are sent, *RPLDEF is done.
      *                        Some codes are created if they don't exist.
      *
      *      *CHANGE           Updates item and tie/high definitions.
      *                        If tie/high defs are sent, *RPLDEF is done.
      *
      *      *DELETE           Deletes item.
      *                        Only requires warehouse and item to be sent.
      *
      *      *ADDDEF           Add item tie/high definitions.
      *                        If def exists, treat as type 'C'.
      *
      *      *CHGDEF           Change item tie/high definitions.
      *                        If def does not exist, treat as type 'A'.
      *
      *      *GETALL           Get all item information.
      *
416dA *      *GETBASE          Get base (parent) item for item sent.
      *
417cA *      *GETNXTMFG        Get next item for mfg item number.
417cA *                        In theory, multiple items can have same mfg#.
417cA *                        $ititem should be blank for the first time
417cA *                        this is called and then the item from the
417cA *                        previous time it was called.
      *
      *      *GETMAIN          Get main item information from PIRITEM.
      *
650bA *      *GEPARENT         Same as get main but will not load KIT item
      *                        information
      *
416dA *      *GETSLOT          Get slot item for item sent.
      *
416dA *      *GETSSB           Get corresponding SSB item for item sent.
      *
      *      *DELDEF           Deletes item tie/high definitions.
      *
      *      *DELALLDEF        Deletes all existing tie/high defs for item.
      *                        Only requires warehouse and item to be sent.
      *
      *      *RPLDEF           Replace existing tie/high defs for item.
      *                        Combination of *DELALLDEF and *ADDDEF.
      *                        Only requires warehouse and item to be sent.
      *
      *      *VERIFY           Same as *GETMAIN.
      *
      *      *VERIFYS          Same as *GETMAIN with the extra verification
      *                        that the item is allowed to go into a slot.
      *                        Currently the only items allowed into a slot
      *                        are ' ' and 'B' types.
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *      *VERIFYDEF        Do definition verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpiritem   uf a e           k disk
     F                                     infds(file1ds)
     Fitemdsc   uf a e           k disk
     F                                     infds(file2ds)
510 AFitemext1  uf a e           k disk
510 AF                                     infds(file11ds)
510aAFkitcomp   uf a e           k disk
510aAF                                     infds(file12ds)
650aAFkititem   uf a e           k disk
650aAF                                     infds(file15ds)
     Fitemdef   uf a e           k disk
     F                                     infds(file3ds)
     Fitemlnk   uf a e           k disk
     F                                     infds(file4ds)
417cAFpiritem4  if   e           k disk
417cAF                                     rename(itrec:itrec4)
720aAFpiritem1  if   e           k disk    prefix(it_)
720aAF                                     rename(itrec:itrec1)
     Fitemlnk1  if   e           k disk
     F                                     rename(ilrec:record1)
     Fitemmsc   uf a e           k disk
     F                                     infds(file5ds)
     Fitemqty   uf a e           k disk
     F                                     infds(file6ds)
     Foptions   if   e           k disk
     Fupc1      uf a e           k disk
     F                                     infds(file7ds)
710a Fupc5      if   e           k disk    rename(uprec:uprec5)
610bDF*temfld   uf a e           k disk
610bDF*                                    infds(file8ds)
500cAFitemsls   uf   e           k disk    usropn
500cAF                                     infds(file9ds)
500cAFitemavg   uf   e           k disk    usropn
500cAF                                     infds(file10ds)
640 AFslot3     uf   e           k disk    rename(slrec:slrec3)
640 AF                                     infds(file13ds)
MRTaAfvslot1    if   e           k disk
740cAfworkrpk   uf a e           k disk    prefix(r_)

610bA*----------------------------------------------------------------
610bA*  File data data structure
610bA*----------------------------------------------------------------
610bA
610bAD ifrec         E ds                  extname(itemfld) inz(*EXTDFT)
700dAD ibrec         E ds                  extname(itembrd) inz(*EXTDFT)

610bA*----------------------------------------------------------------
650aA*
650aA*   definitions to work with user space to setup
650aA*     variable size array for Repack Components
650aA*
650aA*   API to create a user space object
650aA
650aAD CreateUserSpace...
650aAD                 pr                  extpgm('QUSCRTUS')
650aAD   NameAndLib                  20a   const
650aAD   ExtAttr                     10a   const
650aAD   InitSize                    10i 0 const
650aAD   InitValue                    1a   const
650aAD   PublicAut                   10a   const
650aAD   Description                 50a   const
650aAD   Replace                     10a   const
650aAD   ErrorStruct                 16a

650aAD ChangeUserSpaceAttributes...
     *   API to change user space object attributes
650aAD                 pr                  extpgm('QUSCUSAT')
650aAD   LibraryName                 10a
650aAD   NameAndLib                  20a   const
650aAD   Attributes                  10a   const
650aAD   ErrorStruct                 16a

650aAD AttrList        ds                  qualified
650aAD  Size                         10i 0
650aAD  Key                          10i 0
650aAD  DataLength                   10i 0
650aAD  Data                          1a

650aAD SpaceName       s             20a   inz('ARYRPD    QTEMP')
650aAD RtnLib          s             10a
650aAD ErrorStruct     s             16a   inz(*allx'00')

     *   API to retrieve a pointer to the user space
650aAD RtvPtrToUsrSpc  pr                  extpgm('QUSPTRUS')
650aAD   Name                        20a   const
650aAD   Ptr                           *
650aAD   Qusec                             LikeDS(Qusec)

     * API to delete a user space
650aAD DltUsrSpc       pr                  ExtPgm('QUSDLTUS')
650aAD   SpaceName                   20A   Const
650aAD   Errorcde                 32767A

650aAdQusec            ds
650aAd qusbprv                 1      4b 0
650aAd qusbavl                 5      8b 0
650aAd qusei                   9     15
650aAd quserved               16     16

650aAD ptrRPD          s               *
650aA*  Dynamically allocated array stored in the user space
650aAD RepackData      ds                  based(ptrRPD)
650aAD aryRPD                              dim(700)
650aAd  aeitem                       15a   overlay(aryRPD:*next)
650aAD  aedelcd                       1a   overlay(aryRPD:*next)
650aAD  aesitm2                      15a   overlay(aryRPD:*next)
650aAD  aesdisp                      12a   overlay(aryRPD:*next)
650aAD  aesqty1                       3p 0 overlay(aryRPD:*next)
650aAD  aesum1                        2a   overlay(aryRPD:*next)
650aAD  aesqty2                       3p 0 overlay(aryRPD:*next)
650aAD  aesum2                        2a   overlay(aryRPD:*next)
650aAD  aesqty3                       3p 0 overlay(aryRPD:*next)
650aAD  aesum3                        2a   overlay(aryRPD:*next)
650aAD  aerptp                        1a   overlay(aryRPD:*next)
650aAD  aedisp                       12a   overlay(aryRPD:*next)
650aAD  aerqty1                       3p 0 overlay(aryRPD:*next)
650aAD  aerum1                        2a   overlay(aryRPD:*next)
650aAD  aerqty2                       3p 0 overlay(aryRPD:*next)
650aAD  aerum2                        2a   overlay(aryRPD:*next)
650aAd  aesitpe                       1a   overlay(aryRPD:*next)
650aAD  aerqty3                       3p 0 overlay(aryRPD:*next)
650aAD  aerum3                        2a   overlay(aryRPD:*next)
650aAD  aearyrec                      5  0 overlay(aryRPD:*next)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

500aA /copy qcopysrc,id#vigo
GFCaA /copy qcopysrc,id#glazier
VIPaA /COPY QCOPYSRC,ID#VIP
CBIaA /copy qcopysrc,id#cheney
ADFaA /copy qcopysrc,id#adf
MRTaA /copy qcopysrc,id#mrt
GRCaA /copy qcopysrc,id#grc
EOPaA /copy qcopysrc,id#eop
500aAD client          s             10

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP
     D savesubcmd      s                   like($psubcmd)
416dAD savesubcmd2     s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
610aA /COPY *libl/qcopysrc,C#Slot
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10
     D $vsdesc         s              5

     D $vactv          s                   like($itactv)
     D $vbld           s                   like($itbld)
500bAD $vcat           s                   like($ifcat)
     D $vdesg          s                   like($itdesg)
     D $vitem          s                   like($ititem)
     D $vityp          s                   like(ittype)
     D $vsdef          s                   like(idsdef)
     D $vstyp          s                   like(itstyp)
     D $vum            s                   like($itum1)
     D $vwhdp          s                   like($itwhdp)
     D $vwhse          s              3p 0

700cA*----------------------------------------------------------------
700cA*  Called program parameters
700cA*----------------------------------------------------------------

700cAD $lparm          ds
700cAD  $lcmd                  1      8
700cAD  $lprg                  9     18
700cAD  $luky                 19     68
700cAD  $lrtn                 69     76
700cAD  $lerm                 77    136
700cAD  $lmsg                 77     80
700cA*
700cA*   Redefine key
700cA*
700cA*
700cAD  $lcmtype              19     22
700cAD  $lcmcode              23     23
     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

610aAD drislot         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n

     D actcub          s                   like(itcube)
     D chga2b          s               n
     D chga2n          s               n
     D chgb2n          s               n
     D chgn2b          s               n
640bAD cubetest        s             15  3
     D defcount        s              3  0
710bAD dltSpace        s               n
     D curdef          s              3  0
700aAD dltItem         s                   like(ititem)
     D error           s               n
710bAD Errorcde        s          32767a
650aAD nxtItm          s              5  0
650aAD FirstGood       s               n   inz(*off)
650aAD parentItem      s               n   inz(*off)
     D field           s             20
650aAD lookingForS     s              1    inz('0')
     D forever         s               n   inz(*on)
417cAD found           s               n
610bAD foundItemFld    s               n
700aAD i               s              3  0
650gAD ItemLnkDel      s               n
MRTaAd baseODRSlot     s                   like($sldisp)
MRTaAd recCnt          s              5  0
MRTaAd oWhse           s             15  5
610aAD kydisp          s                   like($sldisp)
610bAD kyitem          s                   like(ititem)
     D kysdef          s                   like(idsdef)
     D kywhse          s                   like(itwhse)
     D kyum            s                   like(itum1)
     D lock            s               n
640aMD main2err        s               n
640aMD main2callerr    s               n
640aMD main2rtnerr     s               n
     D pssrflag        s               n
     D svitem          s                   like(ititem)
417bAD svitem2         s                   like(ititem)
740cAD svsession       s                   like($isession)
     D svwhse          s                   like(itwhse)
GFCaAD svimmflg        s                   like(immflg)
650iAD svimltrk        s                   like(imltrk)
640fAD svssbilwhse     s                   like(ilwhse)
640fAD svssbilitm2     s                   like(ilitm2)
640fAD svssbilitem     s                   like(ilitem)

     D #bwhse          s                   like(itwhse)

     D #cdesc          s                   like(itdesc)
     D #citem          s                   like(ititem)
     D #ctype          s                   like(ittype)
     D #cwhse          s                   like(itwhse)

     D #iitem          s                   like(ititem)

     D #litem          s                   like(ititem)
     D #lwhse          s                   like(itwhse)

     D #mdesc          s                   like(itdesc)
     D #mitem          s                   like(ititem)
     D #mtype          s                   like(ittype)
     D #mum1           s                   like(itum1)
     D #mum2           s                   like(itum2)
650aAD #mum3           s                   like(itum3)
     D #mumq2          s                   like(itumq2)
     D #mwhse          s                   like(itwhse)
650aAD #rum1           s                   like(itum1)
650aAD #rum2           s                   like(itum2)
650aAD #rum3           s                   like(itum3)

     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTYP  -  Default section type
     *    OPWHDP  -  Default warehouse department
     *    OPUM1   -  Default normal unit of measure
     *    OPDUM   -  Unit of measure for dimensions
     *    OPCUM   -  Unit of measure for cube
     *    OPCDIV  -  Divisor for cube
     *    OPCAUT  -  Automaticaly calculate cube when zero (Y/N)
     *    OPCWRN  -  Display cube warning (Y/N)
     *    OPCRNG  -  Display cube warning range percentage
     *    OPWUM   -  Unit of measure for weight
     *
     *----------------------------------------------------------------

     D opdata          ds
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  3
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117

610bA*----------------------------------------------------------------
610bA*  Standard SQL variables and constants
610bA*----------------------------------------------------------------
610bA
610bA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

     D File2DS         ds
     D  f2filename             1      8
     D  f2openind              9      9
     D  f2endoffile           10     10
     D  f2status              11     15  0
     D  f2opercode            16     21
     D  f2routine             22     29
     D  f2stmtnbr             30     37
     D  f2recordcd            38     45
     D  f2messageid           46     52
     D  f2sourceid            53     54

     D File3DS         ds
     D  f3filename             1      8
     D  f3openind              9      9
     D  f3endoffile           10     10
     D  f3status              11     15  0
     D  f3opercode            16     21
     D  f3routine             22     29
     D  f3stmtnbr             30     37
     D  f3recordcd            38     45
     D  f3messageid           46     52
     D  f3sourceid            53     54

     D File4DS         ds
     D  f4filename             1      8
     D  f4openind              9      9
     D  f4endoffile           10     10
     D  f4status              11     15  0
     D  f4opercode            16     21
     D  f4routine             22     29
     D  f4stmtnbr             30     37
     D  f4recordcd            38     45
     D  f4messageid           46     52
     D  f4sourceid            53     54

     D File5DS         ds
     D  f5filename             1      8
     D  f5openind              9      9
     D  f5endoffile           10     10
     D  f5status              11     15  0
     D  f5opercode            16     21
     D  f5routine             22     29
     D  f5stmtnbr             30     37
     D  f5recordcd            38     45
     D  f5messageid           46     52
     D  f5sourceid            53     54

     D File6DS         ds
     D  f6filename             1      8
     D  f6openind              9      9
     D  f6endoffile           10     10
     D  f6status              11     15  0
     D  f6opercode            16     21
     D  f6routine             22     29
     D  f6stmtnbr             30     37
     D  f6recordcd            38     45
     D  f6messageid           46     52
     D  f6sourceid            53     54

     D File7DS         ds
     D  f7filename             1      8
     D  f7openind              9      9
     D  f7endoffile           10     10
     D  f7status              11     15  0
     D  f7opercode            16     21
     D  f7routine             22     29
     D  f7stmtnbr             30     37
     D  f7recordcd            38     45
     D  f7messageid           46     52
     D  f7sourceid            53     54

500bAD File8DS         ds
500bAD  f8filename             1      8
500bAD  f8openind              9      9
500bAD  f8endoffile           10     10
500bAD  f8status              11     15  0
500bAD  f8opercode            16     21
500bAD  f8routine             22     29
500bAD  f8stmtnbr             30     37
500bAD  f8recordcd            38     45
500bAD  f8messageid           46     52
500bAD  f8sourceid            53     54

500cA /COPY *libl/qcopysrc,C#file9ds
500cA /COPY *libl/qcopysrc,C#file10ds
510 A /COPY *libl/qcopysrc,C#file11ds
510 B /COPY *libl/qcopysrc,C#file12ds
640 A /COPY *libl/qcopysrc,C#file13ds
650aA /COPY *libl/qcopysrc,C#file15ds

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
416jA *      $pdata2    Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
416aA *      $pmessage  Return code
      *      $pdata     Data returned by command
416jA *      $pdata2    Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
416aAC                   parm                    $pmessage
     C                   parm                    $pdata
416jAC                   parm                    $pdata2

     C                   eval      $item = $pdata
416jAC                   if        %parms >= 6
416jAC                   eval      $item2 = $pdata2
416jAC                   endif
     C                   eval      $preturn = '*OK'
416aAC                   eval      $pmessage = ' '

650aA /free

650aA    // Retrieve the user space array for Repack Item info
650aA    RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD: Qusec);

710bA    dltSpace = *off;
650aA    if qusbavl>0;     // object not found
710bA       // create user space if it did not exist
710bA       CreateUserSpace (SpaceName: *blanks : 32767:
710bA                        X'00': '*ALL': *blanks: '*YES':
710bA                        ErrorStruct);
710bA       AttrList.Size = 1;  // 1 attribute will be changed
710bA       AttrList.Key = 3;   // 3=extensibility attribute
710bA       AttrList.DataLength = 1;
710bA       AttrList.Data = '1'; // user space is extensible
710bA
710bA       // change to extend automatically as needed
710bA       ChangeUserSpaceAttributes (RtnLib: SpaceName: AttrList:
710bA                                  ErrorStruct);
710bA       dltSpace = *on;
710bA
710bA       RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD : Qusec);
650aA    endif;
650aA /end-free

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
610aAC                   exsr      aaaclose
650cAC                   exsr      aaaclsvfypgms
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

650bAc                   if        $psubcmd = '*GETPARENT'
650bAc                   eval      $psubcmd = '*GETMAIN'
650bAc                   eval      parentItem = *on
650bAc                   else
650bAc                   eval      parentItem = *off
650bAc                   endif

     C                   select

     C                   when      $psubcmd = '*ADD'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      additem
     C                   endif
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*CHANGE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      verifychg
     C                   if        not error
     C                   exsr      changeitem
     C                   endif
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*DELETE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      deleteitem
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*GETALL' or
     C                             $psubcmd = '*GETMAIN'
     C                   exsr      getall

416dAC                   when      $psubcmd = '*GETBASE'
416dAC                   exsr      getbase

417cAC                   when      $psubcmd = '*GETNXTMFG'
417cAC                   exsr      getitemmfg
417cAC                   if        not error
417cAC                   eval      $ititem = ititem
417cAC                   exsr      getall
417cAC                   endif

416dAC                   when      $psubcmd = '*GETSLOT'
416dAC                   exsr      getslot

416dAC                   when      $psubcmd = '*GETSSB'
416dAC                   exsr      getssb
650aAC                   eval      lookingForS = '0'

     C                   when      $psubcmd = '*ADDDEF'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      defvfy
     C                   if        not error
     C                   exsr      defupd
     C                   endif
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*CHGDEF'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      defvfy
     C                   if        not error
     C                   exsr      defupd
     C                   endif
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*DELDEF'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      defdel
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*DELALLDEF'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      defdelall
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*RPLDEF'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
416fAC                   endif
     C                   if        not error
     C                   exsr      defvfy
     C                   if        not error
     C                   exsr      defrpl
     C                   endif
     C                   endif
416fDC**                 endif

     C                   when      $psubcmd = '*VERIFY'
     C                   exsr      verify
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
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

     C                   when      $psubcmd = '*VERIFYDEF'
     C                   exsr      defvfy
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   exsr      deleteitem
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYS'
     C                   exsr      verify

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
416aAC                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $item
416jAC                   if        %parms >= 6
416jAC                   eval      $pdata2 = $item2
416jAC                   endif
710bAc                   if        dltSpace
710bA*  remove the user space used between IT112, IT116, and DRIITEM
710bA /free
710bA                    DltUsrSpc(SpaceName: Errorcde);
710bA /end-free
710bAc                   endif
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

500 A* Get client id

500 AC                   call      'GETCLIENT'
500 AC                   parm                    client

     * Key definitions

     *  Define key for PIRITEM file.

     C     keyit         klist
     C                   kfld                    $itwhse
     C                   kfld                    $ititem

700aAC     keyitdel      klist
700aAC                   kfld                    $itwhse
700aAC                   kfld                    dltItem

650eAC     keyitf        klist
650eAC                   kfld                    $itwhse
650eAC                   kfld                    $ititem
650eAC                   kfld                    kccitm
640fA*  Define key for itemlnk file for ssb item
640fA
640fAC     keyitssb      klist
640fAC                   kfld                    svssbilwhse
640fAC                   kfld                    svssbilitem
640fA*  Define key for itemlnk file for saved ssb item
640fA
640fAC     keyitssbsave  klist
640fAC                   kfld                    svssbilwhse
640fAC                   kfld                    svssbilitm2
640fAC                   kfld                    svssbilitem
417cA
417cA*  Define key for PIRITEM4 file.
417cA
417cAC     keyit4        klist
     C                   kfld                    $itwhse
     C                   kfld                    $itvit#

     *  Define key for PIRITEM file for base item.

     C     keyitb        klist
     C                   kfld                    #bwhse
     C                   kfld                    #bitem

     *  Define key for PIRITEM file using Contract Base item.

     C     keyitc        klist
     C                   kfld                    $itwhse
     C                   kfld                    $itcitem

     *  Define key for PIRITEM file using Linked Item.

     C     keyitl        klist
     C                   kfld                    ilwhse
     C                   kfld                    ilitem

     *  Define key for PIRITEM file using Master Item.

     C     keyitm        klist
     C                   kfld                    #mwhse
     C                   kfld                    #mitem

     *  Define key for ITEMLNK file.

     C     keyil         klist
     C                   kfld                    #lwhse
     C                   kfld                    #litem

650eAC     keyilf        klist
650eAC                   kfld                    #lwhse
650eAC                   kfld                    #litem
650eAC                   kfld                    kccitm

     *  Define key for ITEMDEF file.

     C     keyid         klist
     C                   kfld                    $itwhse
     C                   kfld                    $ititem
     C                   kfld                    kysdef
     *
     *
     *  Define key for options file.
     *
     C     optnky        klist
     C                   kfld                    kywhse
     C                   kfld                    opcode

510aA*  Define key for KITCOMP file.
510aA
510aAC     keykit        klist
510aAC                   kfld                    $itwhse
510aAC                   kfld                    $ititem
650aAC                   kfld                    kccitm
510aAC
650aA
650aA*  Define key for KITITEM file (KIT Component data)
650aA
650aAC     keykii        klist
650aAC                   kfld                    $itwhse
650aAC                   kfld                    $ititem
650aAC
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

     *   Get item maintenance options.

     C                   eval      kywhse = $itwhse
     C                   eval      opcode = '*ITEMMNT'

     C     optnky        chain     options
     C                   if        not %found
     C                   eval      opxdsc = 'N'
     C                   eval      opcaut = 'N'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  aaacallhost   Call host program.
     *----------------------------------------------------------------

     C     aaacallhost   begsr

416jAC                   select
416jA
416jAC                   when      %parms <= 5
     C                   call(e)   'DRIMAIN2'
     C                   parm      '*ITEM'       $dricommand
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      'H'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      $item         $dridata
416jA
416jAC                   when      %parms <= 6
416jAC                   call(e)   'DRIMAIN2'
416jAC                   parm      '*ITEM'       $dricommand
416jAC                   parm      $psubcmd      $drisubcmd
416jAC                   parm      'H'           $drisys2upd
416jAC                   parm      $pprogram     $driprogram
416jAC                   parm      ' '           $drireturn
416jAC                   parm      ' '           $drimessage
416jAC                   parm      $item         $dridata
416jAC                   parm      $item2        $dridata2
416jA
416jAC                   endsl

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIMAIN2'
     C                                       + '/' + %trim($dricommand)
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      $drireturn <> '*OK' and
     C                             $drireturn <> '*NOPROGRAM'
     C                   eval      error = *on
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = 'H:' + $drimessage

     C                   endsl

     C                   endsr

610aA*----------------------------------------------------------------
610aA*  aaaclose   Close called programs
610aA*----------------------------------------------------------------
610aA
610aAC     aaaclose      begsr

     C                   eval      $drisubcmd = '*CLOSE'

     C                   if        drislot
     C                   eval      $dricommand = 'DRISLOT'
640aDC**                 exsr      zzzdrimain3
640aDC**                 exsr      zzzdrimain2
     C                   endif

     C                   endsr

650cA*----------------------------------------------------------------
650cA*  aaaclsvfypgms   Close all verify programs that open files.
650cA*----------------------------------------------------------------
650cA
650cAC     aaaclsvfypgms begsr
650cA
650cAC                   eval      $vcommand = '*CLOSE'
650cA
650cAC                   call(e)   'VFYACTV'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      ' '           $vactv
650cAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   call(e)   'VFYBLD'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      ' '           $vbld
650cAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   call(e)   'VFYICAT'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      ' '           $vcat
650cAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   call(e)   'VFYDESG'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      ' '           $vdesg
650cAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   call(e)   'VFYUM'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      ' '           $vum
640gAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vsdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   call(e)   'VFYSDEF'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      0             $vwhse
650cAC                   parm      ' '           $vsdef
650cAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   call(e)   'VFYWHDP'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      0             $vwhse
650cAC                   parm      ' '           $vwhdp
650cAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   call(e)   'VFYWHSE'
650cAC                   parm                    $vcommand
650cAC                   parm      '*NONE'       $vprg
650cAC                   parm      0             $vwhse
650cAC                   parm      ' '           $vdesc
650cAC                   parm      ' '           $vreturn
650cAC                   parm      ' '           $vmessage
650cAC                   parm      ' '           $vmsgk
650cA
650cAC                   endsr

     *----------------------------------------------------------------
     *  addchild  Add child item type records (Alias, Contract, SSB)
     *----------------------------------------------------------------

     C     addchild      begsr

     *  Get master item.

     C                   if        $itmitemu and $itmitem <> ' '
     C                   if        $ittype = 'S' and $itum1 <> ' '
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif
     C                   eval      #mwhse = $itwhse
     C                   eval      #mitem = $itmitem
     C                   exsr      getitemm
     C                   if        error
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   goto      endaddchild
     C                   endif
     C                   endif

     *  Update master item with SSB info.

     *     If 'S' type record and Normal UOM is not blank
     *        force 'S' item UM1 into base UM2
     *        force 'S' item UM2 into base UM3
     *        force 'S' item UM2 QTY into base UM3 QTY
     *        update base item record.

     C                   if        $ittype = 'S' and $itum1 <> ' '

     C                   eval      itum2 = $itum1
     C                   eval      itum3 = $itum2
     C                   eval      itumq3 = $itumq2
     C                   update(e) itrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDMITM'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'MItem" command '
     C                                       + '('
     C                                       + %Trim(%editc(itwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ititem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endaddchild
     C                   endif

     C                   endif

     *  Move information into item fields.

     C                   eval      itwhse = $itwhse
     C                   eval      ititem = $ititem
     C                   eval      ittype = $ittype

     C                   if        $itdescu
     C                   eval      itdesc = $itdesc
     C                   endif

     C                   if        $itpdscu
     C                   eval      itpdsc = $itpdsc
     C                   endif

     *  Add item record.

     C                   write(e)  itrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item" command '
     C                                       + '('
     C                                       + %Trim(%editc(itwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ititem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endaddchild
     C                   endif

     *  Add item quantity record if item is a Contract item.

     C                   if        $ittype = 'C'
     C                   clear                   iqrec
     C                   eval      iqwhse = $itwhse
     C                   eval      iqitem = $ititem
     C                   write(e)  iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIQTY'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'ItemQty" command '
     C                                       + '('
     C                                       + %Trim(%editc(iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iqitem)
     C                                       + ')'
     C                                       + '-' + f6messageid
     C                   goto      endaddchild
     C                   endif
     C                   endif

     *  Add record to ITEMDSC file.

416cDC**                 if        $ixdsc1u or $ixdsc2u
416cMC                   if        $ixdsc1u and $ixdsc1 <> ' ' or
416cAC                             $ixdsc2u and $ixdsc2 <> ' '

     C                   clear                   ixrec
     C                   eval      ixwhse = $itwhse
     C                   eval      ixitem = $ititem
     C                   if        $ixdsc1u
     C                   eval      ixdsc1 = $ixdsc1
     C                   endif
     C                   if        $ixdsc2u
     C                   eval      ixdsc2 = $ixdsc2
     C                   endif
     C                   write(e)  ixrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIDSC'
     C                   eval      $pmessage = 'Error on "Add '
     C                                       + 'Item Desc" command '
     C                                       + '('
     C                                       + %Trim(%editc(ixwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ixitem)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endaddchild
     C                   endif

     C                   endif

     *  Copy ITEMMSC record.

     C     keyitm        chain     itemmsc
     C                   if        %found
     C                   eval      imwhse = $itwhse
     C                   eval      imitem = $ititem
     C                   write(e)  imrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIMSC'
     C                   eval      $pmessage = 'Error on "Add '
     C                                       + 'Item Desc" command '
     C                                       + '('
     C                                       + %Trim(%editc(imwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(imitem)
     C                                       + ')'
     C                                       + '-' + f5messageid
     C                   goto      endaddchild
     C                   endif

     C                   endif
500bA
500bA*  Copy ITEMFLD record.
500bA
610bDC**   keyitm        chain     itemfld
610bDC**                 if        %found
610bDC**                 write(e)  ifrec
610bDC**                 if        %error
610bDC**                 eval      error = *on
610bAC                   eval      kywhse = #mwhse
610bAC                   eval      kyitem = #mitem
610bAC                   exsr      GetItemFld
610bAC                   if        foundItemFld
500bAC                   eval      ifwhse = $itwhse
500bAC                   eval      ifitem = $ititem
610bMC                   exsr      AddItemFld
610bMC                   if        error
500bAC                   eval      $preturn = 'ERRADDIMSC'
500bAC                   eval      $pmessage = 'Error on "Add '
500bAC                                       + 'Item Fld" command '
500bAC                                       + '('
500bAC                                       + %Trim(%editc(ifwhse:'Z'))
500bAC                                       + '/'
500bAC                                       + %trim(ifitem)
500bAC                                       + ')'
500bAC                                       + '-' + f8messageid
500bAC                   goto      endaddchild
500bAC                   endif
500bA
500bAC                   endif

510aA *  Add Kit Component Record (KITCOMP) for Repack Items.
510aA *
650aA /free
740cA     if $ittype = 'R' and $pprogram = 'M17800U';
740cA  // Loop through array with Kit and Kit Component information
740cA        nxtItm = 1;
740cA        FirstGood = *off;
740cA        setll ($isession: $ititem) workrpk;
740cA        dow forever = forever;
740cA          reade ($isession: $ititem) workrpk;
740cA           if %eof(workrpk);
740cA             leave;
740cA           endif;
740cA           if not %eof(workrpk);
740cA             clear kcrec;
740cA             kcwhse = $itwhse;
740cA             kcitem = $ititem;
740cA             kccitm = r_aesitm2;
740cA             kcdisp = r_aedisp;
740cA             kcqty1 = r_aesqty1;
740cA             kcqty2 = r_aesqty2;
740cA             kcqty3 = r_aesqty3;
740cA             write(e)  kcrec;
740cA             if %error;
740cA               error = *on;
740cA               $preturn = 'ERRADDKITC';
740cA               $pmessage = 'Error on "Add   '
740cA                      + 'KitComp" command '
740cA                      + '('
740cA                      + %Trim(%editc(kcwhse:'Z'))
740cA                      + '/'
740cA                      + %trim(kcitem)
740cA                      + ')'
740cA                      + '-' + f12messageid;
740cA             endif;
740cA             if not FirstGood;
740cA                 // Add KITITEM Component record
740cA                 clear kirec;
740cA                 kiwhse = $itwhse;
740cA                 kiitem = $ititem;
740cA                 kirptp = $kirptp;
740cA                 kidisp = $kidisp;
740cA                 kiqty1 = kiqty1;
740cA                 firstGood = *on;
740cA                 write(e)  kirec;
740cA                 if %error;
740cA                    error = *on;
740cA                    $preturn = 'ERRADDKITI';
740cA                    $pmessage = 'Error on "Add   '
740cA                         + 'KitItem" command '
740cA                         + '('
740cA                         + %Trim(%editc(kiwhse:'Z'))
740cA                         + '/'
740cA                         + %trim(kiitem)
740cA                         + ')'
740cA                         + '-' + f12messageid;
740cA                 endif;
740cA              endif;
740cA           endif;
740cA          delete aerec;
740cA        enddo;
740cA     endif;
740cD     //if $ittype = 'R';
740cM     if $ittype = 'R' and $pprogram <> 'M17800U';
650aA  // Loop through array with Kit and Kit Component information
650aA        nxtItm = 1;
650aA        FirstGood = *off;
650aA        dow nxtItm <= %Elem(aryRPD) and not %error
650aA             and aeitem(nxtItm) = $ititem;
650aA           if aeDelcd(nxtItm) = 'G'; //good record for add
650aA               // on first good record add the KITCOMP record
650aA              clear kcrec;
650aA              kcwhse = $itwhse;
650aA              kcitem = $ititem;
650aA              kccitm = aesitm2(nxtItm);
650aA              kcdisp = aedisp(nxtItm);
650aA              kcqty1 = aesqty1(nxtItm);
650aA              kcqty2 = aesqty2(nxtItm);
650aA              kcqty3 = aesqty3(nxtItm);
650aA              write(e)  kcrec;
650aA              if %error;
650aA                 error = *on;
650aA                 $preturn = 'ERRADDKITC';
650aA                 $pmessage = 'Error on "Add   '
650aA                      + 'KitComp" command '
650aA                      + '('
650aA                      + %Trim(%editc(kcwhse:'Z'))
650aA                      + '/'
650aA                      + %trim(kcitem)
650aA                      + ')'
650aA                      + '-' + f12messageid;
650aA              endif;
650aA              if not FirstGood;
650aA                 // Add KITITEM Component record
650aA                 clear kirec;
650aA                 kiwhse = $itwhse;
650aA                 kiitem = $ititem;
650aA                 kirptp = aerptp(nxtItm);
650aA                 kidisp = aesdisp(nxtItm);
650aA                 kiqty1 = aerqty1(nxtItm);
650aA                 kiqty2 = aerqty2(nxtItm);
650aA                 kiqty3 = aerqty3(nxtItm);
650aA                 firstGood = *on;
650aA                 write(e)  kirec;
650aA                 if %error;
650aA                    error = *on;
650aA                    $preturn = 'ERRADDKITI';
650aA                    $pmessage = 'Error on "Add   '
650aA                         + 'KitItem" command '
650aA                         + '('
650aA                         + %Trim(%editc(kiwhse:'Z'))
650aA                         + '/'
650aA                         + %trim(kiitem)
650aA                         + ')'
650aA                         + '-' + f12messageid;
650aA                 endif;
650aA              endif;
650aA           endif;
650aA           nxtItm +=1;
650aA        enddo;
510aA     endif;
650aA /end-free
510aA *

     *  Add record to ITEMLNK file.

650aAc                   if        not %error
     C                   clear                   ilrec

     C                   eval      ilwhse = $itwhse
     C                   eval      ilitem = $ititem
     C                   eval      ilitm2 = $itmitem
     C                   eval      ilitm3 = $itcitem

     C                   write(e)  ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDILNK'
     C                   eval      $pmessage = 'Error on "Add '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      endaddchild
     C                   endif

     *  Add UPC record. Ignore write errors. Assume record exists.

     C                   if        $itupcu and $itupc <> ' '
     C                   clear                   uprec
     C                   eval      upwhse = itwhse
     C                   eval      upitem = ititem
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      itupc         $cstr            30
     C                   move      $cstr         upupc
     C                   eval      upven  = itven#
     C                   write(e)  uprec
     C                   if        %error
     C                   endif
     C                   endif

     *  Copy tie/high definitions.

     C                   exsr      defcpyall
650aAc                   endif

     C     endaddchild   endsr

     *----------------------------------------------------------------
     *  additem   Add item records.
     *----------------------------------------------------------------

     C     additem       begsr

     *  If not Normal or Broken case item, execute child routine.

     C                   if        $ittype <> ' ' and $ittype <> 'B'
510bAC                             and $ittype <> 'R'
     C                   exsr      addchild
     C                   goto      endadditem
     C                   endif

     *  Clear item record.

     C                   clear                   itrec

     *  Move information into item fields.

     *   Note: UPC code ignored.

     C                   eval      itwhse = $itwhse
     C                   eval      ititem = $ititem
     C                   eval      ittype = $ittype

     C                   if        $itdescu
     C                   eval      itdesc = $itdesc
     C                   endif

     C                   if        $itstypu
     C                   eval      itstyp = $itstyp
     C                   endif

     C                   if        $itwhdpu
     C                   eval      itwhdp = $itwhdp
     C                   endif

     C                   if        $itdesgu
     C                   eval      itdesg = $itdesg
     C                   endif

     C                   if        $itactvu
     C                   eval      itactv = $itactv
     C                   endif

     C                   if        $itflgdu
     C                   eval      itflgd = $itflgd
     C                   else
     C                   eval      itflgd = 'N'
     C                   endif

     C                   if        $itflgbu
     C                   eval      itflgb = $itflgb
     C                   else
     C                   eval      itflgb = 'N'
     C                   endif

     C                   if        $itven#u
     C                   eval      itven# = $itven#
     C                   endif

     C                   if        $itvit#u
     C                   eval      itvit# = $itvit#
     C                   endif

     C                   if        $itreplu
     C                   eval      itrepl = $itrepl
     C                   endif

     C                   if        $itpdscu
     C                   eval      itpdsc = $itpdsc
     C                   endif

     C                   if        $itum1u
     C                   eval      itum1 = $itum1
     C                   endif

     C                   if        $itum2u
     C                   eval      itum2 = $itum2
     C                   endif

     C                   if        $itumq2u
     C                   eval      itumq2 = $itumq2
     C                   endif

     C                   if        $itflg1u
     C                   eval      itflg1 = $itflg1
     C                   else
     C                   eval      itflg1 = 'N'
     C                   endif

     C                   if        $itum3u
     C                   eval      itum3 = $itum3
     C                   endif

     C                   if        $itumq3u
     C                   eval      itumq3 = $itumq3
     C                   endif

     C                   if        $itflg2u
     C                   eval      itflg2 = $itflg2
     C                   else
     C                   eval      itflg2 = 'N'
     C                   endif

     C                   if        $itulenu
     C                   eval      itulen = $itulen
     C                   endif

     C                   if        $ituwdtu
     C                   eval      ituwdt = $ituwdt
     C                   endif

     C                   if        $ituhgtu
     C                   eval      ituhgt = $ituhgt
     C                   endif

     C                   if        $itcubeu
     C                   eval      itcube = $itcube
     C                   endif


     C                   if        $itswgtu
     C                   eval      itswgt = $itswgt
     C                   endif

     C                   if        $itcwgtu
     C                   eval      itcwgt = $itcwgt
416hAC                   else
416hAC                   eval      itcwgt = 'N'
     C                   endif

     C                   if        $itbldu
     C                   eval      itbld = $itbld
     C                   endif

     C                   if        $itslifu
     C                   eval      itslif = $itslif
     C                   endif

     C                   if        $itndayu
     C                   eval      itnday = $itnday
     C                   endif

     *  Calculate cube if necessary.

     C                   exsr      calccube

     *  Add item record.

     C                   write(e)  itrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item" command '
     C                                       + '('
     C                                       + %Trim(%editc(itwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ititem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endadditem
     C                   endif

     *  Add item quantity record.

     C                   clear                   iqrec
     C                   eval      iqwhse = $itwhse
     C                   eval      iqitem = $ititem
     C                   write(e)  iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIQTY'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'ItemQty" command '
     C                                       + '('
     C                                       + %Trim(%editc(iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iqitem)
     C                                       + ')'
     C                                       + '-' + f6messageid
     C                   goto      endadditem
     C                   endif
416cA
416cA*  Add record to ITEMDSC file.
416cA
416cAC                   if        $ixdsc1u and $ixdsc1 <> ' ' or
416cAC                             $ixdsc2u and $ixdsc2 <> ' '
416cA
416cAC                   clear                   ixrec
416cAC                   eval      ixwhse = $itwhse
416cAC                   eval      ixitem = $ititem
416cAC                   if        $ixdsc1u
416cAC                   eval      ixdsc1 = $ixdsc1
416cAC                   endif
416cAC                   if        $ixdsc2u
416cAC                   eval      ixdsc2 = $ixdsc2
416cAC                   endif
416cAC                   write(e)  ixrec
416cAC                   if        %error
416cAC                   eval      error = *on
416cAC                   eval      $preturn = 'ERRADDIDSC'
416cAC                   eval      $pmessage = 'Error on "Add '
416cAC                                       + 'Item Desc" command '
416cAC                                       + '('
416cAC                                       + %Trim(%editc(ixwhse:'Z'))
416cAC                                       + '/'
416cAC                                       + %trim(ixitem)
416cAC                                       + ')'
416cAC                                       + '-' + f2messageid
416cAC                   goto      endadditem
416cAC                   endif
416cA
416cAC                   endif

     *  Add record to ITEMMSC file.

     C                   clear                   imrec

     C                   eval      imwhse = $itwhse
     C                   eval      imitem = $ititem

     C                   if        $imtieu
     C                   eval      imtie = $imtie
     C                   endif

     C                   if        $imhighu
     C                   eval      imhigh = $imhigh
     C                   endif

     C                   if        $immflgu
     C                   eval      immflg = $immflg
     C                   else
     C                   eval      immflg = 'N'
     C                   endif

     C                   if        $imddayu
     C                   eval      imdday = $imdday
     C                   endif

     C                   if        $imudayu
     C                   eval      imuday = $imuday
     C                   endif

     C                   if        $immdayu
     C                   eval      immday = $immday
     C                   endif

     C                   if        $imwrncu
     C                   eval      imwrnc = $imwrnc
     C                   else
     C                   eval      imwrnc = 'Y'
     C                   endif

     C                   if        $imrg1cu
     C                   eval      imrg1c = $imrg1c
     C                   endif

     C                   if        $imrg2cu
     C                   eval      imrg2c = $imrg2c
     C                   endif

     C                   if        $imapcku
     C                   eval      imapck = $imapck
     C                   else
     C                   eval      imapck = 'N'
     C                   endif

     C                   if        $imnrpku
     C                   eval      imnrpk = $imnrpk
     C                   else
     C                   if        $itstyp = 'F'
     C                   eval      imnrpk = 1
     C                   else
     C                   eval      imnrpk = *zeros
     C                   endif
     C                   endif

416iAC                   if        $imnsltu
416iAC                   eval      imnslt = $imnslt
416iAC                   else
416iAC                   eval      imnslt = 'N'
416iAC                   endif

416iAC                   if        $imxdcku
416iAC                   eval      imxdck = $imxdck
416iAC                   else
416iAC                   eval      imxdck = 'N'
416iAC                   endif

416iAC                   if        $imbnbru
416iAC                   eval      imbnbr = $imbnbr
416iAC                   endif

416iAC                   if        $imbnamu
416iAC                   eval      imbnam = $imbnam
416iAC                   endif

416iAC                   if        $imvnamu
416iAC                   eval      imvnam = $imvnam
416iAC                   endif

416iAC                   if        $imbrndu
416iAC                   eval      imbrnd = $imbrnd
416iAC                   endif

416iAC                   if        $imlotu
416iAC                   eval      imlot = $imlot
416iAC                   else
416iAC                   eval      imlot = 'N'
416iAC                   endif

416iAC                   if        $imltrku
416iAC                   eval      imltrk = $imltrk
416iAC                   else
500 DC**                 eval      imltrk = 'N'
500 MC                   eval      imltrk = 'L'
416iAC                   endif

417 AC                   if        $imodayu
417 AC                   eval      imoday = $imoday
417 AC                   endif

     C                   write(e)  imrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIMSC'
     C                   eval      $pmessage = 'Error on "Add '
     C                                       + 'Item Misc" command '
     C                                       + '('
     C                                       + %Trim(%editc(imwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(imitem)
     C                                       + ')'
     C                                       + '-' + f5messageid
     C                   goto      endadditem
     C                   endif
500bA
500bA*  Add record to ITEMFLD file.
500bA
610aDC**                 if        $ifcatu and $ifcat <> ' '
610aMC                   if        ($ifcatu and $ifcat <> ' ')
610aAC                             or ($ifodrslotu and $ifodrslot <> ' ')
640aAC                             or ($ifcaseovfu and $ifcaseovf <> ' ')
640eAC                             or ($ifucicdeu and $ifucicde <> ' ')
640eAC                             or ($ifrcvmthu and $ifrcvmth <> ' ')
640eAC                             or ($ifsltmthu and $ifsltmth <> ' ')
640eAC                             or ($ifbrdflgu and $ifbrdflg <> ' ')
500bA
500bAC                   clear                   ifrec
500bAC                   eval      ifwhse = $itwhse
500bAC                   eval      ifitem = $ititem
500bAC                   if        $ifcatu
500bAC                   eval      ifcat = $ifcat
500bAC                   endif
610aAC                   if        $ifodrslotu
650eAC*                  eval      ifodrslot = $ifodrslot
650aAC                   eval      ifodrslot = ' '
610aAC                   endif
640aAC                   if        $ifcaseovfu
640aAC                   eval      ifcaseovf = $ifcaseovf
610aAC                   endif
640dAC                   if        $ifucicdeu
640dAC                   eval      ifucicde = $ifucicde
640dAC                   endif
640dAC                   if        $ifrcvmthu
640dAC                   eval      ifrcvmth = $ifrcvmth
640dAC                   endif
640dAC                   if        $ifsltmthu
640dAC                   eval      ifsltmth = $ifsltmth
640dAC                   endif
640dAC                   if        $ifbrdflgu
640dAC                   eval      ifbrdflg = $ifbrdflg
640dAC                   endif
610bDC**                 write(e)  ifrec
610bDC**                 if        %error
610bDC**                 eval      error = *on
610bAC                   exsr      AddItemFld
610bAC                   if        error
500bAC                   eval      $preturn = 'ERRADDIFLD'
500bAC                   eval      $pmessage = 'Error on "Add '
500bAC                                       + 'Item Fld" command '
500bAC                                       + '('
500bAC                                       + %Trim(%editc(ifwhse:'Z'))
500bAC                                       + '/'
500bAC                                       + %trim(ifitem)
500bAC                                       + ')'
500bAC                                       + '-' + f8messageid
500bAC                   goto      endadditem
500bAC                   endif
500bA
500bAC                   endif

     *   Add record to ITEMLNK file for Brokencase item.
510bA*   and Repack item.

     C                   if        $ittype = 'B'
650eDC*                            or $ittype = 'R'

     C                   clear                   ilrec

     C                   eval      ilwhse = $itwhse
     C                   eval      ilitem = $ititem
     C                   eval      ilitm2 = $itmitem

     C                   write(e)  ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDILNK'
     C                   eval      $pmessage = 'Error on "Add '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      endadditem
     C                   endif

     C                   endif

510aA*  Add Kit Component Record (KITCOMP and KITITEM) for Repack Items.
510aA*
740cA /free
740cA     if $ittype = 'R' and $pprogram = 'M17800U';
740cA  // read the workrpk file
740cA        FirstGood = *off;
740cA        setll ($isession: $ititem) workrpk;
740cA        dow forever = forever;
740cA          reade ($isession: $ititem) workrpk;
740cA           if %eof(workrpk);
740cA             leave;
740cA           endif;
740cA           if not %eof(workrpk);
740cA               // on first good record add the KITCOMP record
740cA              clear kcrec;
740cA              kcwhse = $itwhse;
740cA              kcitem = $ititem;
740cA              kccitm = r_aesitm2;
740cA              kcdisp = r_aedisp;
740cA              kcqty1 = r_aesqty1;
740cA              kcqty2 = r_aesqty2;
740cA              kcqty3 = r_aesqty3;
740cA              write(e)  kcrec;
740cA              if %error;
740cA                 error = *on;
740cA                 $preturn = 'ERRADDKITC';
740cA                 $pmessage = 'Error on "Add   '
740cA                      + 'KitComp" command '
740cA                      + '('
740cA                      + %Trim(%editc(kcwhse:'Z'))
740cA                      + '/'
740cA                      + %trim(kcitem)
740cA                      + ')'
740cA                      + '-' + f12messageid;
740cA              endif;
740cA              if not FirstGood;
740cA                 // Add KITITEM Component record
740cA                 clear kirec;
740cA                 kiwhse = $itwhse;
740cA                 kiitem = $ititem;
740cA                 kirptp = $kirptp;
740cA                 kidisp = $kidisp;
740cA                 kiqty1 = $kiqty1;
740cA                 kiqty2 = $kiqty2;
740cA                 kiqty3 = $kiqty3;
740cA                 firstGood = *on;
740cA                 write(e)  kirec;
740cA                 if %error;
740cA                    error = *on;
740cA                    $preturn = 'ERRADDKITI';
740cA                    $pmessage = 'Error on "Add   '
740cA                         + 'KitItem" command '
740cA                         + '('
740cA                         + %Trim(%editc(kiwhse:'Z'))
740cA                         + '/'
740cA                         + %trim(kiitem)
740cA                         + ')'
740cA                         + '-' + f12messageid;
740cA                 endif;
740cA              endif;
740cA           endif;
740c  /end-free
740c
740cA*   Check/Add Virtual Pick Slot for Merit ODR Repack items
740cA*   if one does not exist
740cAc                   if        client = merit
740cAc                             or client = greco
740cAc                             or client = Earls
740cAc                   eval      oWhse = $itwhse
740cAc                   call      'IT118CL'
740cAc                   parm                    oWhse
740cAc                   parm                    $itwhdp
740cAc                   parm                    kcitem
740cAc                   parm                    kcdisp
740cAc                   endif
740cA
740c
740cA*   Add record to ITEMLNK file for Repack Item.  This code was
740cA*   inserted here since multiple Itemlnk records can now exist
740cA*   for repack item
740cA
740cAC                   if        $ittype = 'R'
740cA
740cAC                   clear                   ilrec
740cA
740cAC                   eval      ilwhse = kcwhse
740cAC                   eval      ilitem = kcitem
740cAC                   eval      ilitm2 = kccitm
740cA
740cAC                   write(e)  ilrec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRADDILNK'
740cAC                   eval      $pmessage = 'Error on "Add '
740cAC                                       + 'Item Link" command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(ilwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(ilitem)
740cAC                                       + '/'
740cAC                                       + %trim(ilitm2)
740cAC                                       + ')'
740cAC                                       + '-' + f4messageid
740cAC                   goto      endadditem
740cAC                   endif
740cA
740cAC                   endif
740c  /free
740cA          delete aerec;
740cA        enddo;
740cA     endif;
740cA /end-free
740cA /free
740cD     //if $ittype = 'R';
740cM     if $ittype = 'R' and $pprogram <> 'M17800U';
650aA  // Loop through array with Kit and Kit Component information
650aA        nxtItm = 1;
650aA        FirstGood = *off;
650aA        dow nxtItm <= %Elem(aryRPD) and not %error
650aA             and aeitem(nxtItm) = $ititem;
650aA           if aeDelcd(nxtItm) = 'G'; //good record for add
650aA               // on first good record add the KITCOMP record
650aA              clear kcrec;
650aA              kcwhse = $itwhse;
650aA              kcitem = $ititem;
650aA              kccitm = aesitm2(nxtItm);
650aA              kcdisp = aedisp(nxtItm);
650aA              kcqty1 = aesqty1(nxtItm);
650aA              kcqty2 = aesqty2(nxtItm);
650aA              kcqty3 = aesqty3(nxtItm);
650aA              write(e)  kcrec;
650aA              if %error;
650aA                 error = *on;
650aA                 $preturn = 'ERRADDKITC';
650aA                 $pmessage = 'Error on "Add   '
650aA                      + 'KitComp" command '
650aA                      + '('
650aA                      + %Trim(%editc(kcwhse:'Z'))
650aA                      + '/'
650aA                      + %trim(kcitem)
650aA                      + ')'
650aA                      + '-' + f12messageid;
650aA              endif;
650aA              if not FirstGood;
650aA                 // Add KITITEM Component record
650aA                 clear kirec;
650aA                 kiwhse = $itwhse;
650aA                 kiitem = $ititem;
650aA                 kirptp = aerptp(nxtItm);
650aA                 kidisp = aesdisp(nxtItm);
650aA                 kiqty1 = aerqty1(nxtItm);
650aA                 kiqty2 = aerqty2(nxtItm);
650aA                 kiqty3 = aerqty3(nxtItm);
650aA                 firstGood = *on;
650aA                 write(e)  kirec;
650aA                 if %error;
650aA                    error = *on;
650aA                    $preturn = 'ERRADDKITI';
650aA                    $pmessage = 'Error on "Add   '
650aA                         + 'KitItem" command '
650aA                         + '('
650aA                         + %Trim(%editc(kiwhse:'Z'))
650aA                         + '/'
650aA                         + %trim(kiitem)
650aA                         + ')'
650aA                         + '-' + f12messageid;
650aA                 endif;
650aA              endif;
650aA           endif;
      /end-free

MRTaA*   Check/Add Virtual Pick Slot for Merit ODR Repack items
MRTaA*   if one does not exist
MRTaAc                   if        client = merit
GRCaAc                             or client = greco
EOPaAc                             or client = Earls
MRTaAc                   eval      oWhse = $itwhse
MRTaAc                   call      'IT118CL'
MRTaAc                   parm                    oWhse
MRTaAc                   parm                    $itwhdp
MRTaAc                   parm                    kcitem
MRTaAc                   parm                    kcdisp
MRTaAc                   endif
MRTaA

650eA*   Add record to ITEMLNK file for Repack Item.  This code was
650eA*   inserted here since multiple Itemlnk records can now exist
650eA*   for repack item
650eA
650eAC                   if        $ittype = 'R'
650eA
650eAC                   clear                   ilrec
650eA
650eAC                   eval      ilwhse = kcwhse
650eAC                   eval      ilitem = kcitem
650eAC                   eval      ilitm2 = kccitm
650eA
650eAC                   write(e)  ilrec
650eAC                   if        %error
650eAC                   eval      error = *on
650eAC                   eval      $preturn = 'ERRADDILNK'
650eAC                   eval      $pmessage = 'Error on "Add '
650eAC                                       + 'Item Link" command '
650eAC                                       + '('
650eAC                                       + %Trim(%editc(ilwhse:'Z'))
650eAC                                       + '/'
650eAC                                       + %trim(ilitem)
650eAC                                       + '/'
650eAC                                       + %trim(ilitm2)
650eAC                                       + ')'
650eAC                                       + '-' + f4messageid
650eAC                   goto      endadditem
650eAC                   endif
650eA
650eAC                   endif
      /free
650aA           nxtItm +=1;
650aA        enddo;
650aA     endif;
650aA /end-free
510aA *
     *  Add UPC record. Ignore write errors. Assume record exists.

650aAc                   if        not %Error
     C                   if        $itupcu and $itupc <> ' '
     C                   clear                   uprec
     C                   eval      upwhse = itwhse
     C                   eval      upitem = ititem
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      itupc         $cstr            30
     C                   move      $cstr         upupc
     C                   eval      upven  = itven#
     C                   write(e)  uprec
     C                   if        %error
     C                   endif
     C                   endif

     *   Add item tie/high definitions.

     C                   exsr      defupd
650aAc                   endif

     C     endadditem    endsr

     *----------------------------------------------------------------
     *  calccube  Calculate cube for item.
     *----------------------------------------------------------------

     C     calccube      begsr

     *  See if we should auto-calculate cube.

     *      Auto calculate option is 'Y'
     *      and Cube is zero

     *      or force calculation if cube is -1.

     C                   if        opcaut = 'Y' and itcube = 0 or
     C                             itcube = -1

     C                   if        opcdiv > 0
     C                   eval(h)   itcube = (itulen * ituwdt * ituhgt) /
     C                                      opcdiv
     C                   endif

     C                   endif

     C     endcalccube   endsr

     *----------------------------------------------------------------
     *  changechild  Change child item records (Alias, Contract, SSB)
     *----------------------------------------------------------------

     C     changechild   begsr

     *  Update main item record.

     *    Move information into item fields.

     C                   if        $ittypeu
     C                   eval      ittype = $ittype
     C                   endif

     C                   if        $itdescu
     C                   eval      itdesc = $itdesc
     C                   endif

     C                   if        $itpdscu
     C                   eval      itpdsc = $itpdsc
     C                   endif

     *    Update item record.

     C                   update(e) itrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item" command '
     C                                       + '('
     C                                       + %Trim(%editc(itwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ititem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endchgchild
     C                   endif

     *  Add item quantity record if item is a Contract item.

     C                   if        $ittype = 'C'

     C     keyit         chain(n)  itemqty
     C                   if        not %found
     C                   clear                   iqrec
     C                   eval      iqwhse = $itwhse
     C                   eval      iqitem = $ititem
     C                   write(e)  iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIQTY'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'ItemQty" command '
     C                                       + '('
     C                                       + %Trim(%editc(iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iqitem)
     C                                       + ')'
     C                                       + '-' + f6messageid
     C                   goto      endchgchild
     C                   endif
     C                   endif

     C                   endif

     *  Update ITEMDSC record (add if not found).

416cDC**                 if        not $ixdsc1u and
416cDC**                           not $ixdsc2u
416cMC                   if        not $ixdsc1u and not $ixdsc2u or
416cAC                             $ixdsc1u and $ixdsc1 = ' ' and
416cAC                             $ixdsc2u and $ixdsc2 = ' '
     C                   goto      skipidscupd2
     C                   endif

     *    Get ITEMDSC record.

     C     keyit         chain     itemdsc
     C                   if        not %found
     C                   clear                   ixrec
     C                   endif

     *    Move information into ITEMDSC fields.

     C                   if        $ixdsc1u
     C                   eval      ixdsc1 = $ixdsc1
     C                   endif
     C                   if        $ixdsc2u
     C                   eval      ixdsc2 = $ixdsc2
     C                   endif

     *    Add record if it wasn't found.

     C                   select
     C                   when      not %found
     C                   eval      ixwhse = $itwhse
     C                   eval      ixitem = $ititem
     C                   write(e)  ixrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIDSC'
     C                   eval      $pmessage = 'Error on "Add '
     C                                       + 'Item Desc" command '
     C                                       + '('
     C                                       + %Trim(%editc(ixwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ixitem)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endchgchild
     C                   endif

     *    Otherwise update record.

     C                   other
     C                   update(e) ixrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDIDSC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item Desc" command '
     C                                       + '('
     C                                       + %Trim(%editc(ixwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ixitem)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endchgchild
     C                   endif

     C                   endsl

     C     skipidscupd2  tag

510aA*    Get KITCOMP record, if 'R' Repack Item
740cAC                   if        $ittype = 'R' and $pprogram = 'M17800U'
740cA*   LOOP through component array with Kit component info
740cA /free
740cA        setll ($isession: $ititem) workrpk;
740cA        dow forever = forever;
740cA          reade ($isession: $ititem) workrpk;
740cA           if %eof(workrpk);
740cA             leave;
740cA           endif;
740cA           if not %eof(workrpk);
740cA
740cA /end-free
740cAc                   eval      kccitm = r_aesitm2
740cAC     keykit        chain     kitcomp
740cAC                   if        not %found
740cAC                   clear                   kcrec
740cAC                   endif
740cA
740cA*    Move information into KITCOMP fields.
740cA
740cAc                   eval      kcdisp = R_aesdisp
740cA
740cAC                   eval      kcqty1 = r_aesqty1
740cA
740cAC                   eval      kcqty2 = r_aesqty2
740cA
740cAC                   eval      kcqty3 = r_aesqty3
740cA
740cA*    Add record if it wasn't found.
740cA
740cAC                   select
740cAC                   when      not %found
740cAC                   eval      kcwhse = $itwhse
740cAC                   eval      kcitem = $ititem
740cAC                   eval      kccitm = r_aesitm2
740cAC                   write(e)  kcrec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRADDKITC'
740cAC                   eval      $pmessage = 'Error on "Write '
740cAC                                       + 'KitComp " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgchild
740cAC                   endif
740cA
740cA*    Otherwise update record.
740cA
740cAC                   other
740cAC                   eval      kcwhse = $itwhse
740cAC                   eval      kcitem = $ititem
740cAC                   eval      kccitm = r_aesitm2
740cAC                   update(e) kcrec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRUPDKITC'
740cAC                   eval      $pmessage = 'Error on "Update '
740cAC                                       + 'KitComp " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgchild
740cAC                   endif
740cA
740cAC                   endsl
740cA*  change/add information to KitItem with component info
740cAc                   if        not FirstGood
740cAc                   eval      FirstGood = *on
740cAC     keykii        chain     kititem
740cAC                   if        not %found
740cAC                   clear                   kirec
740cAC                   endif
740cA*    Move information into KITITEM fields.
740cA
740cAC                   if        $kidispu
740cAC                   eval      kidisp = $kidisp
740cAC                   endif
740cA
740cAC                   if        $kirptpu
740cAC                   eval      kirptp = $kirptp
740cAC                   endif
740cA
740cAC                   if        $kiqty1u
740cAC                   eval      kiqty1 = $kiqty1
740cAC                   endif
740cA
740cA*    Add record if it wasn't found.
740cA
740cAC                   select
740cAC                   when      not %found
740cAC                   eval      kiwhse = $itwhse
740cAC                   eval      kiitem = $ititem
740cAC                   write(e)  kirec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRADDKITI'
740cAC                   eval      $pmessage = 'Error on "Write '
740cAC                                       + 'KitItem " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgchild
740cAC                   endif
740cA
740cA*    Otherwise update record.
740cA
740cAC                   other
740cA*  if status not delete then update component record
740cAc                   if        aeDelcd(nxtItm) <> 'D'
740cAC                   eval      kiwhse = $itwhse
740cAC                   eval      kiitem = $ititem
740cAC                   update(e) kirec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRUPDKITI'
740cAC                   eval      $pmessage = 'Error on "Update '
740cAC                                       + 'KitItem " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgchild
740cAC                   endif
740cA
740cA*   Check/Add Virtual Pick Slot for Merit ODR Repack items
740cA*   if one does not exist
740cAc                   if        client = merit
740cAc                             or client = greco
740cAc                             or client = Earls
740cAc                   eval      oWhse = $itwhse
740cAc                   call      'IT118CL'
740cAc                   parm                    oWhse
740cAc                   parm                    $itwhdp
740cAc                   parm                    kcitem
740cAc                   parm                    kcdisp
740cAc                   endif
740cA
740cA *  requesting that component record be deleted as part of change
740cAc                   else
740cAc                   delete    kirec
740cAc                   endif
740cA
740cAC                   endsl
740cA *   endif for not FirstGood
740cAc                   endif
740cA *   enddo for KITITEM loop
740cAc                   endif
740cAc                   delete    aerec
740cAc                   enddo
740cAC                   endif
650aA
740cDC*                  if        $ittype = 'R'
740cMC                   if        $ittype = 'R' and $pprogram <> 'M17800U'
650AA*   LOOP through component array with Kit component info
650aAc                   eval      nxtItm = 1
650aAc                   dow       nxtItm <= %Elem(aryRPD) and
650aAc                                 not %error and
650aAc                                 aeitem(nxtItm) = $ititem
650aAc                   if        aeDelcd(nxtItm) = 'G'
650aAc                               or aeDelcd(nxtItm) = 'D'
650aA
650aAc                   eval      kccitm = aesitm2(nxtItm)
650aAC     keykit        chain     kitcomp
650aAC                   if        not %found
650aAc                   if        aeDelcd(nxtItm) = 'D'
650aAc                   eval      nxtItm = nxtItm + 1
650aAc                   iter
650aAc                   endif
650aAC                   clear                   kcrec
650aAC                   endif
650aA
650aA*    Move information into KITCOMP fields.
650aA
650aAc                   if        $kcdispu
650aAc                   eval      kcdisp = aesdisp(nxtItm)
650aAc                   endif
650aA
650aAC                   if        $kcqty1u
650eAC*                  eval      kcqty1 = $kcqty1
650aAC                   eval      kcqty1 = aesqty1(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kcqty2u
650eAC*                  eval      kcqty2 = $kcqty2
650eAC                   eval      kcqty2 = aesqty2(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kcqty3u
650eAC*                  eval      kcqty3 = $kcqty3
650aAC                   eval      kcqty3 = aesqty3(nxtItm)
650aAC                   endif
650aA
650aA*    Add record if it wasn't found.
650aA
650aAC                   select
650aAC                   when      not %found
650aAC                   eval      kcwhse = $itwhse
650aAC                   eval      kcitem = $ititem
650cAC                   eval      kccitm = aesitm2(nxtItm)
650aAC                   write(e)  kcrec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRADDKITC'
650aAC                   eval      $pmessage = 'Error on "Write '
650aAC                                       + 'KitComp " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgchild
650aAC                   endif
650aA
650aA*    Otherwise update record.
650aA
650aAC                   other
650aAC                   eval      kcwhse = $itwhse
650aAC                   eval      kcitem = $ititem
650cAC                   eval      kccitm = aesitm2(nxtItm)
650aAC                   update(e) kcrec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRUPDKITC'
650aAC                   eval      $pmessage = 'Error on "Update '
650aAC                                       + 'KitComp " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgchild
650aAC                   endif
650aA
650aAC                   endsl
650aA*  change/add information to KitItem with component info
650aAc                   if        not FirstGood
650aAc                   eval      FirstGood = *on
650aAC     keykii        chain     kititem
650aAC                   if        not %found
650aAC                   clear                   kirec
650aAC                   endif
650aA*    Move information into KITITEM fields.
650aA
650aAC                   if        $kidispu
650eAC                   eval      kidisp = aedisp(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kirptpu
650eAC                   eval      kirptp = aerptp(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kiqty1u
650eAC                   eval      kiqty1 = aerqty1(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kiqty2u
650eAC                   eval      kiqty2 = aerqty2(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kiqty3u
650aAC                   eval      kiqty3 = aerqty3(nxtItm)
650aAC                   endif
650aA
650aA*    Add record if it wasn't found.
650aA
650aAC                   select
650aAC                   when      not %found
650aAC                   eval      kiwhse = $itwhse
510aAC                   eval      kiitem = $ititem
650aAC                   write(e)  kirec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRADDKITI'
650aAC                   eval      $pmessage = 'Error on "Write '
650aAC                                       + 'KitItem " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgchild
650aAC                   endif
650aA
650aA*    Otherwise update record.
650aA
650aAC                   other
650aA*  if status not delete then update component record
650aAc                   if        aeDelcd(nxtItm) <> 'D'
650aAC                   eval      kiwhse = $itwhse
650aAC                   eval      kiitem = $ititem
650aAC                   update(e) kirec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRUPDKITI'
650aAC                   eval      $pmessage = 'Error on "Update '
650aAC                                       + 'KitItem " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgchild
650aAC                   endif

MRTaA*   Check/Add Virtual Pick Slot for Merit ODR Repack items
MRTaA*   if one does not exist
MRTaAc                   if        client = merit
GRCaAc                             or client = greco
EOPaAc                             or client = Earls
MRTaAc                   eval      oWhse = $itwhse
MRTaAc                   call      'IT118CL'
MRTaAc                   parm                    oWhse
MRTaAc                   parm                    $itwhdp
MRTaAc                   parm                    kcitem
MRTaAc                   parm                    kcdisp
MRTaAc                   endif
MRTaA
650aA *  requesting that component record be deleted as part of change
650aAc                   else
650aAc                   delete    kirec
650aAc                   endif
650aA
650aAC                   endsl
650aA *   endif for not FirstGood
650aAc                   endif
650aA *   endif for aeDelcd = 'G'  good record
650aAC                   endif
650aAc                   eval      nxtItm =nxtItm + 1
650aA *   enddo for KITITEM loop
650aAc                   enddo
510aAC                   endif
510aA
     *  Update ITEMLNK record (add if not found).

     *    Get ITEMLNK record.

     C     keyit         chain     itemlnk
     C                   if        not %found
     C                   clear                   ilrec
     C                   endif

     *    Move information into ITEMLNK fields.

     C                   if        $itmitemu
     C                   eval      ilitm2 = $itmitem
     C                   endif

     C                   if        $itcitemu
     C                   eval      ilitm3 = $itcitem
     C                   endif

     *    Add record if it wasn't found.

     C                   select
     C                   when      not %found
     C                   eval      ilwhse = $itwhse
     C                   eval      ilitem = $ititem
     C                   write(e)  ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDILNK'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      endchgchild
     C                   endif

     *    Otherwise update record.

     C                   other
     C                   update(e) ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDILNK'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      endchgchild
     C                   endif

     C                   endsl

     C     endchgchild   endsr

     *----------------------------------------------------------------
     *  changeitem  Change item records.
     *----------------------------------------------------------------

     C     changeitem    begsr

     *  Get & lock item.

     C                   eval      lock = *on
     C                   exsr      getitem
     C                   if        error
     C                   eval      error = *on
     C                   eval      $ititeme = '1'
     C                   goto      endchgitem
     C                   endif

     *  If not Normal or Broken case item, execute child routine.

     C                   if        $ittypeu and $ittype = ' ' or
     C                             not $ittypeu and ittype = ' ' or
     C                             $ittypeu and $ittype = 'B' or
510bMC                             not $ittypeu and ittype = 'B' or
510bAC                             $ittypeu and $ittype = 'R' or
510bAC                             not $ittypeu and ittype = 'R'
     C                   else
     C                   exsr      changechild
     C                   goto      endchgitem
     C                   endif

     *  Update main item record.

     *    Move information into item fields.

     *      Note: UPC code ignored.

     C                   if        $ittypeu
     C                   eval      ittype = $ittype
     C                   endif

     C                   if        $itdescu
     C                   eval      itdesc = $itdesc
     C                   endif

     C                   if        $itstypu
     C                   eval      itstyp = $itstyp
     C                   endif

     C                   if        $itwhdpu
     C                   eval      itwhdp = $itwhdp
     C                   endif

     C                   if        $itdesgu
     C                   eval      itdesg = $itdesg
     C                   endif

     C                   if        $itactvu
     C                   eval      itactv = $itactv
     C                   endif

     C                   if        $itflgdu
GFCaA*  For specified client/s, if item is changed from date sensitive
GFCaA*  to non date sensitive, send %ZEROEXPD to DRISLOT to zero the
GFCaA*  slot expiration date in all slots and licenses for this item.
GFCaAC                   select
GFCaAC                   when      (client = glazier
VIPaAC                             or client = VIP)
GFCaAC                             and itflgd  = 'Y'
GFCaAC                             and $itflgd = 'N'
GFCaAC                   exsr      clr$slot
GFCaAC                   eval      $slwhseu = *on
GFCaAC                   eval      $slwhse  = $itwhse
GFCaAC                   eval      $slitemu = *on
GFCaAC                   eval      $slitem  = $ititem
GFCaAC                   eval      $dricommand = 'DRISLOT'
GFCaAC                   eval      $drisubcmd  = '%ZEROEXPD'
GFCaAC                   eval      $drisys2upd = 'D'
GFCaAC                   exsr      zzzdrimain2
GFCaAC                   endsl
     C                   eval      itflgd = $itflgd
     C                   endif

     C                   if        $itflgbu
     C                   eval      itflgb = $itflgb
     C                   endif

     C                   if        $itven#u
     C                   eval      itven# = $itven#
     C                   endif

     C                   if        $itvit#u
     C                   eval      itvit# = $itvit#
     C                   endif

     C                   if        $itreplu
     C                   eval      itrepl = $itrepl
     C                   endif

     C                   if        $itpdscu
     C                   eval      itpdsc = $itpdsc
     C                   endif

     C                   if        $itum1u
     C                   eval      itum1 = $itum1
     C                   endif

     C                   if        $itum2u
     C                   eval      itum2 = $itum2
     C                   endif

     C                   if        $itumq2u
     C                   eval      itumq2 = $itumq2
     C                   endif

     C                   if        $itflg1u
     C                   eval      itflg1 = $itflg1
     C                   endif

     C                   if        $itum3u
     C                   eval      itum3 = $itum3
     C                   endif

     C                   if        $itumq3u
     C                   eval      itumq3 = $itumq3
     C                   endif

     C                   if        $itflg2u
     C                   eval      itflg2 = $itflg2
     C                   endif

     C                   if        $itulenu
     C                   eval      itulen = $itulen
     C                   endif

     C                   if        $ituwdtu
     C                   eval      ituwdt = $ituwdt
     C                   endif

     C                   if        $ituhgtu
     C                   eval      ituhgt = $ituhgt
     C                   endif

     C                   if        $itcubeu
     C                   eval      itcube = $itcube
     C                   endif

     C                   if        $itswgtu
     C                   eval      itswgt = $itswgt
     C                   endif

     C                   if        $itcwgtu
     C                   eval      itcwgt = $itcwgt
     C                   endif

     C                   if        $itbldu
     C                   eval      itbld = $itbld
     C                   endif

     C                   if        $itslifu
     C                   eval      itslif = $itslif
     C                   endif

     C                   if        $itndayu
     C                   eval      itnday = $itnday
     C                   endif

     *    Calculate cube if necessary.

     C                   if        $itcubeu
     C                   exsr      calccube
     C                   endif

     *    Update item record.

     C                   update(e) itrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item" command '
     C                                       + '('
     C                                       + %Trim(%editc(itwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ititem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endchgitem
     C                   endif

     C     skipitemupd1  tag

     *  Add ITEMQTY record if it does not exist.

     C     keyit         chain(n)  itemqty
     C                   if        not %found
     C                   clear                   iqrec
     C                   eval      iqwhse = $itwhse
     C                   eval      iqitem = $ititem
     C                   write(e)  iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIQTY'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'ItemQty" command '
     C                                       + '('
     C                                       + %Trim(%editc(iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iqitem)
     C                                       + ')'
     C                                       + '-' + f6messageid
     C                   goto      endchgitem
     C                   endif
     C                   endif

     *  Update ITEMDSC record (add if not found).

416cDC**                 if        not $ixdsc1u and
416cDC**                           not $ixdsc2u
416cMC                   if        not $ixdsc1u and not $ixdsc2u or
416cAC                             $ixdsc1u and $ixdsc1 = ' ' and
416cAC                             $ixdsc2u and $ixdsc2 = ' '
     C                   goto      skipidscupd1
     C                   endif

     *    Get ITEMDSC record.

     C     keyit         chain     itemdsc
     C                   if        not %found
     C                   clear                   ixrec
     C                   endif

     *    Move information into ITEMDSC fields.

     C                   if        $ixdsc1u
     C                   eval      ixdsc1 = $ixdsc1
     C                   endif
     C                   if        $ixdsc2u
     C                   eval      ixdsc2 = $ixdsc2
     C                   endif

     *    Add record if it wasn't found.

     C                   select
     C                   when      not %found
     C                   eval      ixwhse = $itwhse
     C                   eval      ixitem = $ititem
     C                   write(e)  ixrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIDSC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item Desc" command '
     C                                       + '('
     C                                       + %Trim(%editc(ixwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ixitem)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endchgitem
     C                   endif

     *    Otherwise update record.

     C                   other
     C                   update(e) ixrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDIDSC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item Desc" command '
     C                                       + '('
     C                                       + %Trim(%editc(ixwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ixitem)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endchgitem
     C                   endif

     C                   endsl

     C     skipidscupd1  tag

     *  Update ITEMMSC record (add if not found).

     C                   if        not $imtieu  and
     C                             not $imhighu and
     C                             not $immflgu and
     C                             not $imddayu and
     C                             not $imudayu and
     C                             not $immdayu and
     C                             not $imwrncu and
     C                             not $imrg1cu and
     C                             not $imrg2cu and
     C                             not $imapcku and
     C                             not $imnrpku and
416iAC                             not $imnsltu and
416iAC                             not $imxdcku and
416iAC                             not $imbnbru and
416iAC                             not $imbnamu and
416iAC                             not $imvnamu and
416iAC                             not $imbrndu and
416iAC                             not $imlotu  and
416iAC                             not $imltrku and
417 AC                             not $imodayu
     C                   goto      skipimscupd1
     C                   endif

     *    Get ITEMMSC record.

     C     keyit         chain     itemmsc
     C                   if        not %found
     C                   clear                   imrec
     C                   endif

     *    Move information into ITEMMSC fields.

     C                   if        $imtieu
     C                   eval      imtie = $imtie
     C                   endif

     C                   if        $imhighu
     C                   eval      imhigh = $imhigh
     C                   endif

     C                   if        $immflgu
GFCaAC                   eval      svimmflg = immflg
     C                   eval      immflg = $immflg
     C                   endif

     C                   if        $imddayu
     C                   eval      imdday = $imdday
     C                   endif

     C                   if        $imudayu
     C                   eval      imuday = $imuday
     C                   endif

     C                   if        $immdayu
     C                   eval      immday = $immday
GFCaA*  For specified client/s, if the item was and is a mfg dated item and
GFCaA*  the mfg shelf life days has changed, send %SETFIFOG to DRISLOT to
GFCaA*  recalculate the expiration date and update all licenses and slots
GFCaA*  for this item with the new expiration date.
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                             and svimmflg = 'Y'
GFCaAC                             and immflg = 'Y'
GFCaAC                   exsr      clr$slot
GFCaAC                   eval      $slwhseu = *on
GFCaAC                   eval      $slwhse  = $itwhse
GFCaAC                   eval      $slitemu = *on
GFCaAC                   eval      $slitem  = $ititem
GFCaAC                   eval      $saIMMDAYu = *on
GFCaAC                   eval      $saIMMDAY = immday
GFCaAC                   eval      $saITFLGDu = *on
GFCaAC                   eval      $saITFLGD = itflgd
GFCaAC                   eval      $dricommand = 'DRISLOT'
GFCaAC                   eval      $drisubcmd  = '%SETFIFOG'
GFCaAC                   eval      $drisys2upd = 'D'
GFCaAC                   exsr      zzzdrimain2
GFCaAC                   endsl
     C                   endif

     C                   if        $imwrncu
     C                   eval      imwrnc = $imwrnc
     C                   endif

     C                   if        $imrg1cu
     C                   eval      imrg1c = $imrg1c
     C                   endif

     C                   if        $imrg2cu
     C                   eval      imrg2c = $imrg2c
     C                   endif

     C                   if        $imapcku
     C                   eval      imapck = $imapck
     C                   endif

     C                   if        $imnrpku
     C                   eval      imnrpk = $imnrpk
     C                   endif

416iAC                   if        $imnsltu
416iAC                   eval      imnslt = $imnslt
416iAC                   endif

416iAC                   if        $imxdcku
416iAC                   eval      imxdck = $imxdck
416iAC                   endif

416iAC                   if        $imbnbru
416iAC                   eval      imbnbr = $imbnbr
416iAC                   endif

416iAC                   if        $imbnamu
416iAC                   eval      imbnam = $imbnam
416iAC                   endif

416iAC                   if        $imvnamu
416iAC                   eval      imvnam = $imvnam
416iAC                   endif

416iAC                   if        $imbrndu
416iAC                   eval      imbrnd = $imbrnd
416iAC                   endif

416iAC                   if        $imlotu
416iAC                   eval      imlot = $imlot
416iAC                   endif

416iAC                   if        $imltrku
650iAC                   eval      svimltrk = imltrk
416iAC                   eval      imltrk = $imltrk
416iAC                   endif

417 AC                   if        $imodayu
417 AC                   eval      imoday = $imoday
417 AC                   endif

     *    Add record if it wasn't found.

     C                   select
     C                   when      not %found
     C                   eval      imwhse = $itwhse
     C                   eval      imitem = $ititem
     C                   write(e)  imrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDIMSC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item Misc" command '
     C                                       + '('
     C                                       + %Trim(%editc(imwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(imitem)
     C                                       + ')'
     C                                       + '-' + f5messageid
     C                   goto      endchgitem
     C                   endif

     *    Otherwise update record.

     C                   other
     C                   update(e) imrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDIMSC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item Misc" command '
     C                                       + '('
     C                                       + %Trim(%editc(imwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(imitem)
     C                                       + ')'
     C                                       + '-' + f5messageid
     C                   goto      endchgitem
     C                   endif

     C                   endsl

650iA*  If tracking level changed from L to M/H, call pgm
650iA*  to move *MULTI licenses to virtual slots
650iAC                   select
650iAC                   when      svimltrk = 'L'
650iAC                             and imltrk <> 'L'
650iAC                             or svimltrk = ' '
650iAC                             and imltrk <> 'L'
650iAC                   call(e)   'IT821CL'
650iAC                   parm      $itwhse       $xwhse           15 5
650iAC                   parm      $itwhdp       $xdept            5
650iAC                   parm      $ititem       $xitem           15
650iAC                   endsl

     C     skipimscupd1  tag
500bA
500bA*  Update ITEMFLD record (add if not found).
500bA
500bAC                   if        not $ifcatu
610aAC                             and not $ifodrslotu
640aAC                             and not $ifcaseovfu
640dAC                             and not $ifucicdeu
640dAC                             and not $ifrcvmthu
640dAC                             and not $ifsltmthu
640dAC                             and not $ifbrdflgu
500bAC                   goto      skipifldupd1
500bAC                   endif
500bA
500bA*    Get ITEMFLD record.
500bA
610bDC**   keyit         chain     itemfld
610bDC**                 if        not %found
610bAC                   eval      kyWhse = $itwhse
610bAC                   eval      kyitem = $ititem
610bAC                   exsr      GetItemFld
610bAC                   if        not foundItemFld
500bAC                   clear                   ifrec
500bAC                   endif
500bA
500bA*    Move information into ITEMFLD fields.
500bA
500bAC                   if        $ifcatu
500bAC                   eval      ifcat = $ifcat
500bAC                   endif
500bA
610aAC                   if        $ifodrslotu
610aAC                   eval      ifodrslot = $ifodrslot
610aAC                   endif
640aAC                   if        $ifcaseovfu
640aAC                   eval      ifcaseovf = $ifcaseovf
640aAC                   endif
640dAC                   if        $ifucicdeu
640dAC                   eval      ifucicde = $ifucicde
640dAC                   endif
640dAC                   if        $ifrcvmthu
640dAC                   eval      ifrcvmth = $ifrcvmth
640dAC                   endif
640dAC                   if        $ifsltmthu
640dAC                   eval      ifsltmth = $ifsltmth
640dAC                   endif
640dAC                   if        $ifbrdflgu
640dAC                   eval      ifbrdflg = $ifbrdflg
640dAC                   endif
500bA
500bA*    Add record if it wasn't found.
500bA
500bAC                   select
610bDC**                 when      not %found
610bMC                   when      not foundItemFld
500bAC                   eval      ifwhse = $itwhse
500bAC                   eval      ifitem = $ititem
610bDC**                 write(e)  ifrec
610bDC**                 if        %error
610bDC**                 eval      error = *on
610bAC                   exsr      AddItemFld
610bAC                   if        error
500bAC                   eval      $preturn = 'ERRADDIFLD'
500bAC                   eval      $pmessage = 'Error on "Write '
500bAC                                       + 'Item Fld" command '
500bAC                                       + '('
500bAC                                       + %Trim(%editc(ifwhse:'Z'))
500bAC                                       + '/'
500bAC                                       + %trim(ifitem)
500bAC                                       + ')'
500bAC                                       + '-' + f8messageid
500bAC                   goto      endchgitem
500bAC                   endif
500bA
500bA*    Otherwise update record.
500bA
500bAC                   other
610bDC**                 update(e) ifrec
610bDC**                 if        %error
610bMC                   exsr      UpdItemFld
610bMC                   if        error
500bAC                   eval      error = *on
500bAC                   eval      $preturn = 'ERRUPDIFLD'
500bAC                   eval      $pmessage = 'Error on "Update '
500bAC                                       + 'Item Fld" command '
500bAC                                       + '('
500bAC                                       + %Trim(%editc(ifwhse:'Z'))
500bAC                                       + '/'
500bAC                                       + %trim(ifitem)
500bAC                                       + ')'
500bAC                                       + '-' + f8messageid
500bAC                   goto      endchgitem
500bAC                   endif
500bA
500bAC                   endsl
500bA
500bAC     skipifldupd1  tag

650gAc                   eval      ItemLnkDel = *off
510aA*    Get KITCOMP record, if 'R' Repack Item
740cAC                   if        $ittype = 'R' and $pprogram = 'M17800U'
740cA*   LOOP through component array with Kit component info
740cAc                   eval      nxtItm = 1
740cA /free
740cA        setll ($isession: $ititem) workrpk;
740cA        dow forever = forever;
740cA          reade ($isession: $ititem) workrpk;
740cA           if %eof(workrpk);
740cA             leave;
740cA           endif;
740cA /end-free
740cA
740cAc                   eval      kccitm = r_aesitm2
740cAC     keykit        chain     kitcomp
740cAC                   if        not %found
740cAc**    need to handle delete
740cAc**                 if        aeDelcd(nxtItm) = 'D'
740cAc**                 eval      ItemLnkDel = *on
740cAc**                 exsr      updMiscItem
740cAc**                 endif
740cAC                   clear                   kcrec
740cAC                   endif
740cA
740cA*    Move information into KITCOMP fields.
740cA
740cAc                   eval      kcdisp = r_aesdisp
740c
740cAC                   eval      kcqty1 = r_aesqty1
740cA
740cAC                   eval      kcqty2 = r_aesqty2
740cA
740cAC                   eval      kcqty3 = r_aesqty3
740cA
740cA*    Add record if it wasn't found.
740cA
740cAC                   select
740cAC                   when      not %found
740cAC                   eval      kcwhse = $itwhse
740cAC                   eval      kcitem = $ititem
740cAC                   eval      kccitm = r_aesitm2
740cAC                   write(e)  kcrec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRADDKITC'
740cAC                   eval      $pmessage = 'Error on "Write '
740cAC                                       + 'KitComp " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgitem
740cAC                   endif
740cA
740cA*    Otherwise update record.
740cA
740cAC                   other
740cA *   delete of component item requested
740cAc***                if        aeDelcd(nxtItm) <> 'D'
740cAC                   eval      kcwhse = $itwhse
740cAC                   eval      kcitem = $ititem
740cAC                   update(e) kcrec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRUPDKITC'
740cAC                   eval      $pmessage = 'Error on "Update '
740cAC                                       + 'KitComp " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgitem
740cAC                   endif
740cA *  delete component record in kitcomp
740cAc***                else
740cAc***                delete    kcrec
740cA *   endif for aeDelcd <> 'D'
740cAc***                endif
740cA
740cAC                   endsl
740cA*  change/add information to KitItem with component info
740cAc                   if        not FirstGood
740cAc                   eval      FirstGood = *on
740cAC     keykii        chain     kititem
740cAC                   if        not %found
740cAC                   clear                   kirec
740cAC                   endif
740cA*    Move information into KITITEM fields.
740cA
740cAC                   if        $kidispu
740cAC                   eval      kidisp = $kidisp
740cAC                   endif
740cA
740cAC                   if        $kirptpu
740cAC                   eval      kirptp = $kirptp
740cAC                   endif
740cA
740cAC                   if        $kiqty1u
740cAC                   eval      kiqty1 = $kiqty1
740cAC                   endif
740cA
740cAC                   if        $kiqty2u
740cAC                   eval      kiqty2 = $kiqty2
740cAC                   endif
740cA
740cAC                   if        $kiqty3u
740cAC                   eval      kiqty3 = $kiqty3
740cAC                   endif
740cA
740cA*    Add record if it wasn't found.
740cA
740cAC                   select
740cAC                   when      not %found
740cAC                   eval      kiwhse = $itwhse
740cAC                   eval      kiitem = $ititem
740cAC                   write(e)  kirec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRADDKITI'
740cAC                   eval      $pmessage = 'Error on "Write '
740cAC                                       + 'KitItem " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgitem
740cAC                   endif
740cA
740cA*    Otherwise update record.
740cA
740cAC                   other
740cA
740cAC                   eval      kiwhse = $itwhse
740cAC                   eval      kiitem = $ititem
740cAC                   update(e) kirec
740cAC                   if        %error
740cAC                   eval      error = *on
740cAC                   eval      $preturn = 'ERRUPDKITI'
740cAC                   eval      $pmessage = 'Error on "Update '
740cAC                                       + 'KitItem " command '
740cAC                                       + '('
740cAC                                       + %Trim(%editc(kcwhse:'Z'))
740cAC                                       + '/'
740cAC                                       + %trim(kcitem)
740cAC                                       + ')'
740cAC                                       + '-' + f12messageid
740cAC                   goto      endchgitem
740cAC                   endif
740cA
740cAC                   endsl
740cA *   endif for not FirstGood
740cAc                   endif
740cA *   endif for aeDelcd = 'G'  good record
740cA*   Check/Add Virtual Pick Slot for Merit ODR Repack items
740cA*   if one does not exist
740cAc                   if        client = merit
740cAc                             or client = greco
740cAc                             or client = Earls
740cAc                   eval      oWhse = $itwhse
740cAc                   call      'IT118CL'
740cAc                   parm                    oWhse
740cAC                   parm                    $itwhdp
740cAc                   parm                    kcitem
740cAc                   parm                    kcdisp
740cAc                   endif
740cA
740cAC*******            endif
740cA *   enddo for KITCOMP loop
740cA *   widen the KITCOMP loop to encompass all the Itemlnk updates
740cA *   since the Itemlnk file can now hold multiple records when
740cA *   Repack Item has multiple records
740cA *   Reinstate kit loop here and move Itemlnk loop into separate
740cA *   routine since it is currently only updating when type R or B
740ca*   move certain updates to routine so they can be called for
740ca*   repack items.  Repacks can now contain more than 1 parent
740cAc                   exsr      updMiscItem
740cAc                   eval      nxtItm =nxtItm + 1
740cAc****               delete    aerec
740cMc                   enddo
740cMc** now remove any records that were deleted from workrpk
740cA /free
740cA   setll ($itwhse: $ititem) kitcomp;
740cA   dow forever = forever;
740cA     reade ($itwhse: $ititem) kitcomp;
740cA     if %eof(kitcomp);
740cA       leave;
740cA     endif;
740cA     chain ($isession: kcitem: kccitm) workrpk;
740cA     if not %found(workrpk);
740cA       delete kcrec;
740cA     endif;
740cA   enddo;
740cA /end-free
740cAc                   endif
740cDC**                 if        $ittype = 'R'
740cMC                   if        $ittype = 'R' and $pprogram <> 'M17800U'
650AA*   LOOP through component array with Kit component info
650aAc                   eval      nxtItm = 1
650aAc                   dow       nxtItm <= %Elem(aryRPD) and
650aAc                                 not %error and
650aAc                                 aeitem(nxtItm) = $ititem
650aAc                   if        aeDelcd(nxtItm) = 'G'
650aAc                               or aeDelcd(nxtItm) = 'D'
510aA
650aAc                   eval      kccitm = aesitm2(nxtItm)
650aAC     keykit        chain     kitcomp
650aAC                   if        not %found
650aAc                   if        aeDelcd(nxtItm) = 'D'
650eDc*                  eval      nxtItm = nxtItm + 1
650gAc                   eval      ItemLnkDel = *on
650gDc*                  goto      ItemLnkDelete
650gAc                   exsr      updMiscItem
650aAc                   endif
650aAC                   clear                   kcrec
650aAC                   endif
650aA
650aA*    Move information into KITCOMP fields.
650aA
650aAc                   if        $kcdispu
650aAc                   eval      kcdisp = aesdisp(nxtItm)
650aAc                   endif

650aAC                   if        $kcqty1u
650eAC*                  eval      kcqty1 = $kcqty1
650aAC                   eval      kcqty1 = aesqty1(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kcqty2u
650eAC*                  eval      kcqty2 = $kcqty2
650eAC                   eval      kcqty2 = aesqty2(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kcqty3u
650eAC*                  eval      kcqty3 = $kcqty3
650aAC                   eval      kcqty3 = aesqty3(nxtItm)
650aAC                   endif
650aA
650aA*    Add record if it wasn't found.
650aA
650aAC                   select
650aAC                   when      not %found
650aAC                   eval      kcwhse = $itwhse
650aAC                   eval      kcitem = $ititem
650cAC                   eval      kccitm = aesitm2(nxtItm)
650aAC                   write(e)  kcrec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRADDKITC'
650aAC                   eval      $pmessage = 'Error on "Write '
650aAC                                       + 'KitComp " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgitem
650aAC                   endif
650aA
650aA*    Otherwise update record.
650aA
650aAC                   other
650aA *   delete of component item requested
650aAc                   if        aeDelcd(nxtItm) <> 'D'
650aAC                   eval      kcwhse = $itwhse
650aAC                   eval      kcitem = $ititem
650aAC                   update(e) kcrec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRUPDKITC'
650aAC                   eval      $pmessage = 'Error on "Update '
650aAC                                       + 'KitComp " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgitem
650aAC                   endif
650aA *  delete component record in kitcomp
650aAc                   else
650aAc                   delete    kcrec
650aA *   endif for aeDelcd <> 'D'
650aAc                   endif
650aA
650aAC                   endsl
650aA*  change/add information to KitItem with component info
650aAc                   if        not FirstGood
650aAc                   eval      FirstGood = *on
650aAC     keykii        chain     kititem
650aAC                   if        not %found
650aAC                   clear                   kirec
650aAC                   endif
650aA*    Move information into KITITEM fields.
650aA
650aAC                   if        $kidispu
650eAC                   eval      kidisp = aedisp(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kirptpu
650eAC                   eval      kirptp = aerptp(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kiqty1u
650eAC                   eval      kiqty1 = aerqty1(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kiqty2u
650eAC                   eval      kiqty2 = aerqty2(nxtItm)
650aAC                   endif
650aA
650aAC                   if        $kiqty3u
650aAC                   eval      kiqty3 = aerqty3(nxtItm)
650aAC                   endif
650aA
650aA*    Add record if it wasn't found.
650aA
650aAC                   select
650aAC                   when      not %found
650aAC                   eval      kiwhse = $itwhse
510aAC                   eval      kiitem = $ititem
650aAC                   write(e)  kirec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRADDKITI'
650aAC                   eval      $pmessage = 'Error on "Write '
650aAC                                       + 'KitItem " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgitem
650aAC                   endif
650aA
650aA*    Otherwise update record.
650aA
650aAC                   other
650aA
650aAC                   eval      kiwhse = $itwhse
650aAC                   eval      kiitem = $ititem
650aAC                   update(e) kirec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRUPDKITI'
650aAC                   eval      $pmessage = 'Error on "Update '
650aAC                                       + 'KitItem " command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kcwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kcitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      endchgitem
650aAC                   endif
650aA
650aAC                   endsl
650aA *   endif for not FirstGood
650aAc                   endif
650aA *   endif for aeDelcd = 'G'  good record
MRTaA*   Check/Add Virtual Pick Slot for Merit ODR Repack items
MRTaA*   if one does not exist
MRTaAc                   if        client = merit
GRCaAc                             or client = greco
EOPaAc                             or client = Earls
MRTaAc                   eval      oWhse = $itwhse
MRTaAc                   call      'IT118CL'
MRTaAc                   parm                    oWhse
MRTaAC                   parm                    $itwhdp
MRTaAc                   parm                    kcitem
MRTaAc                   parm                    kcdisp
MRTaAc                   endif
MRTaA
650aAC                   endif
650aA *   enddo for KITCOMP loop
650eA *   widen the KITCOMP loop to encompass all the Itemlnk updates
650eA *   since the Itemlnk file can now hold multiple records when
650eA *   Repack Item has multiple records
650gA *   Reinstate kit loop here and move Itemlnk loop into separate
650gA *   routine since it is currently only updating when type R or B
650ga*   move certain updates to routine so they can be called for
650ga*   repack items.  Repacks can now contain more than 1 parent
650gAc                   exsr      updMiscItem
650gAc                   eval      nxtItm =nxtItm + 1
650gMc                   enddo
650gMc                   endif
510aA
650gA*  include exsr updMiscItem for non R type record
650gAc                   if        $ittype <> 'R'
650hAC                   if        nxtItm = 0
650hAc                   eval      nxtItm = nxtItm + 1
650hAC                   endif
650gAc                   exsr      updMiscItem
650gAc                   endif
650ag** Move loop back up and move linked record loop into separate
650ag** routine.  updMiscItem records
650eA** Move the loop for the KITCOMP(Repack) items to encompass the
650eA** Itemlnk updates since repacks can now have more than 1 parent
650eA** and Itemlnk key was changed to also have more than 1 record
650gDc*                  eval      nxtItm =nxtItm + 1
650gDc*                  enddo
650gDC*                  endif

     C     endchgitem    endsr

650gA*----------------------------------------------------------------
650gA*  updMiscItem  Update Misc data from changeitem routine
650gA*----------------------------------------------------------------

650gAC     updMiscItem   begsr
     *  Update ITEMLNK record for Breakdown item (add if not found).

650gAc                   if        not ItemLnkDel
     C                   if        $ittype = 'B'
650aDC*                            or $ittype = 'R'
650eMC                             or $ittype = 'R'

     *    Get ITEMLNK record.

650gAc                   if        $ittype <> 'R'
650eDC*    keyit         chain     itemlnk
650gAC     keyit         chain     itemlnk
650gAc                   else
650eAC     keyitf        chain     itemlnk
650gAc                   endif
     C                   if        not %found
     C                   clear                   ilrec
     C                   endif

     *    Move information into ITEMMSC fields.

650cDC*                  if        $itmitemu or $itmitem <> ' '
650gAc                   if        $ittype <> 'R'
650cDC*                  eval      ilitm2 = $itmitem
650gAC                   eval      ilitm2 = $itmitem
650gAc                   else
650cAC                   eval      ilitm2 = kccitm
650gAc                   endif
650cDC*                  endif

     *    Add record if it wasn't found.

     C                   select
     C                   when      not %found
     C                   eval      ilwhse = $itwhse
     C                   eval      ilitem = $ititem
     C                   write(e)  ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDILNK'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      endMiscItem
     C                   endif

     *    Otherwise update record.

     C                   other
     C                   update(e) ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDILNK'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      endMiscItem
     C                   endif

     C                   endsl

     C                   endif
650gAc                   endif

     *  Try and delete ITEMLNK record for a Normal item.

650gAc                   eval      ItemLnkDel = *off
650gDc*    ItemLnkDelete TAG
     C                   if        ittype = ' '
650kAc                              or nxtitm > 0
650kDc*                             or aeDelcd(nxtItm) = 'D'
650kMc                              and aeDelcd(nxtItm) = 'D'

     C                   eval      lock = *on
     C                   eval      #lwhse = $itwhse
     C                   eval      #litem = $ititem
     C                   exsr      getlinkf
     C                   if        error
     C                   eval      error = *off
     C                   else
     C                   delete(e) ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELILNK'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      endMiscItem
     C                   endif
     C                   endif

     C                   endif

     *  Update item tie/high definitions.

     C                   if        $idsdefu(1) or
     C                             $idsdefu(2) or
     C                             $idsdefu(3) or
     C                             $idsdefu(4) or
     C                             $idsdefu(5)
     C                   exsr      defrpl
     C                   endif

     *  Update any linked (dependent) items.

     *    Loop through linked items.

     C     keyit         setll     itemlnk1
     C                   dow       forever = forever

     C     keyit         reade     itemlnk1
     C                   if        %eof
     C                   leave
     C                   endif

     *    Update linked item record.

     *      Get & lock record

     C     keyitl        chain     piritem
     C                   if        not %found
     C                   iter
     C                   endif

     *      If Normal or Broken case item, get next linked item.
510bA*      or Repack item

     C                   if        ittype = ' ' or ittype = 'B'
510bAC                             or ittype = 'R'
     C                   iter
     C                   endif

     *      Move information into item fields.

     C                   if        $itstypu
     C                   eval      itstyp = $itstyp
     C                   endif

     C                   if        $itwhdpu
     C                   eval      itwhdp = $itwhdp
     C                   endif

     C                   if        $itdesgu
     C                   eval      itdesg = $itdesg
     C                   endif

     C                   if        $itactvu
     C                   eval      itactv = $itactv
     C                   endif

     C                   if        $itflgdu
     C                   eval      itflgd = $itflgd
     C                   endif

     C                   if        $itflgbu
     C                   eval      itflgb = $itflgb
     C                   endif

     C                   if        $itven#u
     C                   eval      itven# = $itven#
     C                   endif

     C                   if        $itvit#u
     C                   eval      itvit# = $itvit#
     C                   endif

     C                   if        $itreplu
     C                   eval      itrepl = $itrepl
     C                   endif

     C                   if        $itum1u
     C                   eval      itum1 = $itum1
     C                   endif

     C                   if        $itum2u
     C                   eval      itum2 = $itum2
     C                   endif

     C                   if        $itumq2u
     C                   eval      itumq2 = $itumq2
     C                   endif

     C                   if        $itflg1u
     C                   eval      itflg1 = $itflg1
     C                   endif

     C                   if        $itum3u
     C                   eval      itum3 = $itum3
     C                   endif

     C                   if        $itumq3u
     C                   eval      itumq3 = $itumq3
     C                   endif

     C                   if        $itflg2u
     C                   eval      itflg2 = $itflg2
     C                   endif

     C                   if        $itulenu
     C                   eval      itulen = $itulen
     C                   endif

     C                   if        $ituwdtu
     C                   eval      ituwdt = $ituwdt
     C                   endif

     C                   if        $ituhgtu
     C                   eval      ituhgt = $ituhgt
     C                   endif

     C                   if        $itcubeu
     C                   eval      itcube = $itcube
     C                   exsr      calccube
     C                   endif

     C                   if        $itswgtu
     C                   eval      itswgt = $itswgt
     C                   endif

     C                   if        $itcwgtu
     C                   eval      itcwgt = $itcwgt
     C                   endif

     C                   if        $itbldu
     C                   eval      itbld = $itbld
     C                   endif

     C                   if        $itslifu
     C                   eval      itslif = $itslif
     C                   endif

     C                   if        $itndayu
     C                   eval      itnday = $itnday
     C                   endif

     *      Update item record.

     C                   update(e) itrec
     C                   if        %error
     C                   endif

     *    Update linked itemmsc record.

     *      Get & lock record


     C     keyitl        chain     itemmsc
     C                   if        not %found
     C                   iter
     C                   endif

     *      Move information into ITEMMSC fields.

     C                   if        $imtieu
     C                   eval      imtie = $imtie
     C                   endif

     C                   if        $imhighu
     C                   eval      imhigh = $imhigh
     C                   endif

     C                   if        $immflgu
     C                   eval      immflg = $immflg
     C                   endif

     C                   if        $imddayu
     C                   eval      imdday = $imdday
     C                   endif

     C                   if        $imudayu
     C                   eval      imuday = $imuday
     C                   endif

     C                   if        $immdayu
     C                   eval      immday = $immday
     C                   endif

     C                   if        $imwrncu
     C                   eval      imwrnc = $imwrnc
     C                   endif

     C                   if        $imrg1cu
     C                   eval      imrg1c = $imrg1c
     C                   endif

     C                   if        $imrg2cu
     C                   eval      imrg2c = $imrg2c
     C                   endif

     C                   if        $imapcku
     C                   eval      imapck = $imapck
     C                   endif

     C                   if        $imnrpku
     C                   eval      imnrpk = $imnrpk
     C                   endif

416iAC                   if        $imnsltu
416iAC                   eval      imnslt = $imnslt
416iAC                   endif

416iAC                   if        $imxdcku
416iAC                   eval      imxdck = $imxdck
416iAC                   endif

416iAC                   if        $imbnbru
416iAC                   eval      imbnbr = $imbnbr
416iAC                   endif

416iAC                   if        $imbnamu
416iAC                   eval      imbnam = $imbnam
416iAC                   endif

416iAC                   if        $imvnamu
416iAC                   eval      imvnam = $imvnam
416iAC                   endif

416iAC                   if        $imbrndu
416iAC                   eval      imbrnd = $imbrnd
416iAC                   endif

416iAC                   if        $imlotu
416iAC                   eval      imlot = $imlot
416iAC                   endif

416iAC                   if        $imltrku
416iAC                   eval      imltrk = $imltrk
416iAC                   endif

417 AC                   if        $imodayu
417 AC                   eval      imoday = $imoday
417 AC                   endif

     *      Update itemmsc record.

     C                   update(e) imrec
     C                   if        %error
     C                   endif
500bA
500bA*    Update linked itemmsc record.
500bA
500bA*      Get & lock record
500bA
610bDC**   keyitl        chain     itemfld
610bDC**                 if        not %found
610bAC                   eval      kyWhse = ilwhse
610bAC                   eval      kyItem = ilitem
610bAC                   exsr      GetItemFld
610bAC                   if        not foundItemFld
500bAC                   iter
500bAC                   endif
500bA
500bA*      Move information into ITEMFLD fields.
500bA
500bAC                   if        $ifcatu
500bAC                   eval      ifcat = $ifcat
500bAC                   endif
500bA
610aAC                   if        $ifodrslotu
610aAC                   eval      ifodrslot = $ifodrslot
610aAC                   endif
640aAC                   if        $ifcaseovfu
640aAC                   eval      ifcaseovf = $ifcaseovf
640aAC                   endif
640dAC                   if        $ifucicdeu
640dAC                   eval      ifucicde = $ifucicde
640dAC                   endif
640dAC                   if        $ifrcvmthu
640dAC                   eval      ifrcvmth = $ifrcvmth
640dAC                   endif
640dAC                   if        $ifsltmthu
640dAC                   eval      ifsltmth = $ifsltmth
640dAC                   endif
640dAC                   if        $ifbrdflgu
640dAC                   eval      ifbrdflg = $ifbrdflg
640dAC                   endif
500bA
500bA*      Update itemfld record.
500bA
610bDC**                 update(e) ifrec
610bDC**                 if        %error
610bAC                   exsr      UpdItemFld
610bAC                   if        error
610bAC                   eval      error = *off
500bAC                   endif

     *    Replace linked item tie/high definitions.

     C                   if        $idsdefu(1) or
     C                             $idsdefu(2) or
     C                             $idsdefu(3) or
     C                             $idsdefu(4) or
     C                             $idsdefu(5)
     C                   exsr      defrpllnk
     C                   endif

640fA * Dependent items for ssb items are not being updated to match base item
640fAc                   if        ittype = 'S'
640fAc                   exsr      updssbdepitm
640fAc                   endif
     C                   enddo

     ** End of update linked records loop **
650gAC     endMiscItem   endsr

     *----------------------------------------------------------------
     *  checkmitem  Check master item.
     *----------------------------------------------------------------

     C     checkmitem    begsr

     *  Master cannot be the same as main item.

     C                   if        #mitem = $ititem
     C                   eval      error = *on
     C                   eval      $ititeme = '1'
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'INVLDI&M'
416aAC                   exsr      getmsg
     C                   goto      endchkmitem
     C                   endif

     *  Verify master item.

     C                   eval      lock = *off
     C                   exsr      getitemm
     C                   if        error
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   goto      endchkmitem
     C                   endif

     *  If Alias item is being created ...
     *    Then master item must be Normal, Breakdown or SSB.
510bA*    or Repack.

     C                   if        $ittype = 'A'
     C                   if        #mtype <> ' ' and
     C                             #mtype <> 'B' and
510bAC                             #mtype <> 'R' and
     C                             #mtype <> 'S'
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'INVLDMTYPA'
     C                   exsr      getmsg
     C                   goto      endchkmitem
     C                   endif
     C                   endif

     *  If Contract item is being created ...
     *    Then master item must be Normal or Breakdown.
510bA*    or Repack.

     C                   if        $ittype = 'C'
     C                   if        #mtype <> ' ' and
510bMC                             #mtype <> 'B' and
510bAC                             #mtype <> 'R'
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'INVLDMTYPC'
     C                   exsr      getmsg
     C                   goto      endchkmitem
     C                   endif
     C                   endif

     *  If SSB item is being created ...
     *    Then master item must be Normal or Breakdown.

     C                   if        $ittype = 'S'
     C                   if        #mtype <> ' ' and
     C                             #mtype <> 'B'
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'INVLDMTYPS'
     C                   exsr      getmsg
     C                   goto      endchkmitem
     C                   endif
     C                   endif

     *  If Breakdown item is being created ...
     *    Then master item must be Normal.

     C                   if        $ittype = 'B'
     C                   if        #mtype <> ' '
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'INVLDMTYPB'
     C                   exsr      getmsg
     C                   goto      endchkmitem
     C                   endif
     C                   endif

650cA*     Also allow item type "R"
510bA*  If Repack item is being created ...
510bA*    Then master item must be Normal.
510bA
510bAC                   if        $ittype = 'R'
510bAC                   if        #mtype <> ' '
650cAc                              and #mtype <>'R'
510bAC                   eval      error = *on
510bAC                   eval      $itmiteme = '1'
510bAC                   eval      $preturn = 'INVLDMTYPR'
510bAC                   exsr      getmsg
510bAC                   goto      endchkmitem
510bAC                   endif
510bAC                   endif

     *  For Broken case or SSB item, base breakdown must be defined.

     C                   if        $ittype = 'B' or $ittype = 'S'
     C                   if        #mum2 = *blanks or
     C                             #mumq2 <= 0
     C                   eval      error = *on
     C                   eval      $preturn = 'BRKNOTDEF'
416aAC                   exsr      getmsg
     C                   goto      endchkmitem
     C                   endif
     C                   endif

     C     endchkmitem   endsr

     *----------------------------------------------------------------
     *  chktypchg  Check if item type can be changed.
     *----------------------------------------------------------------

     C     chktypchg     begsr

     C                   eval      chga2n = *off
     C                   eval      chga2b = *off
     C                   eval      chgb2n = *off
     C                   eval      chgn2b = *off

     *  Only allowed to type change from . . .

     C                   select

     *    Normal to Breakdown

     C                   when      ittype = ' ' and $ittype = 'B'
     C                   eval      chgn2b = *on

     *    Breakdown to Normal

     C                   when      ittype = 'B' and $ittype = ' '
     C                   eval      chgb2n = *on

     *    Alias to Normal

     C                   when      ittype = 'A' and $ittype = ' '
     C                   eval      chga2n = *on

     *    Alias to Breakdown

     C                   when      ittype = 'A' and $ittype = 'B'
     C                   eval      chga2b = *on

     *  Otherwise, it's an error.

     C                   other
     C                   eval      error = *on
416aAC                   eval      $preturn = 'INVLDTYPCG'
416aAC                   exsr      getmsg

     C                   endsl

     C     endckt        endsr

     *----------------------------------------------------------------
     *  cleardefflags  Clear error flag fields for tie/high definitions
     *----------------------------------------------------------------

     C     cleardefflags begsr

     C                   eval      curdef = 0
     C                   dou       curdef = %elem($idsdef)
     C                   eval      curdef = curdef + 1

     C                   if        $idsdefe(curdef) = '1'
     C                   eval      $idsdefe(curdef) = '0'
     C                   endif

     C                   if        $idtiee(curdef) = '1'
     C                   eval      $idtiee(curdef) = '0'
     C                   endif

     C                   if        $idhighe(curdef) = '1'
     C                   eval      $idhighe(curdef) = '0'
     C                   endif

     C                   if        $idume(curdef) = '1'
     C                   eval      $idume(curdef) = '0'
     C                   endif

     C                   if        $idprefe(curdef) = '1'
     C                   eval      $idprefe(curdef) = '0'
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $itwhsee = '1'
     C                   eval      $itwhsee = '0'
     C                   endif

     C                   if        $ititeme = '1'
     C                   eval      $ititeme = '0'
     C                   endif

     C                   if        $itmiteme = '1'
     C                   eval      $itmiteme = '0'
     C                   endif

     C                   if        $itciteme = '1'
     C                   eval      $itciteme = '0'
     C                   endif

     C                   if        $ittypee = '1'
     C                   eval      $ittypee = '0'
     C                   endif

     C                   if        $itdesce = '1'
     C                   eval      $itdesce = '0'
     C                   endif

     C                   if        $itstype = '1'
     C                   eval      $itstype = '0'
     C                   endif

     C                   if        $itwhdpe = '1'
     C                   eval      $itwhdpe = '0'
     C                   endif

     C                   if        $itdesge = '1'
     C                   eval      $itdesge = '0'
     C                   endif

     C                   if        $itactve = '1'
     C                   eval      $itactve = '0'
     C                   endif

     C                   if        $itupce = '1'
     C                   eval      $itupce = '0'
     C                   endif

     C                   if        $itblde = '1'
     C                   eval      $itblde = '0'
     C                   endif

     C                   if        $itven#e = '1'
     C                   eval      $itven#e = '0'
     C                   endif

     C                   if        $itvit#e = '1'
     C                   eval      $itvit#e = '0'
     C                   endif

     C                   if        $itpdsce = '1'
     C                   eval      $itpdsce = '0'
     C                   endif

     C                   if        $itum1e = '1'
     C                   eval      $itum1e = '0'
     C                   endif

     C                   if        $itum2e = '1'
     C                   eval      $itum2e = '0'
     C                   endif

     C                   if        $itumq2e = '1'
     C                   eval      $itumq2e = '0'
     C                   endif

     C                   if        $itflg1e = '1'
     C                   eval      $itflg1e = '0'
     C                   endif

     C                   if        $itum3e = '1'
     C                   eval      $itum3e = '0'
     C                   endif

     C                   if        $itumq3e = '1'
     C                   eval      $itumq3e = '0'
     C                   endif

     C                   if        $itflg2e = '1'
     C                   eval      $itflg2e = '0'
     C                   endif

     C                   if        $itulene = '1'
     C                   eval      $itulene = '0'
     C                   endif

     C                   if        $ituwdte = '1'
     C                   eval      $ituwdte = '0'
     C                   endif

     C                   if        $ituhgte = '1'
     C                   eval      $ituhgte = '0'
     C                   endif

     C                   if        $itcubee = '1'
     C                   eval      $itcubee = '0'
     C                   endif

     C                   if        $itswgte = '1'
     C                   eval      $itswgte = '0'
     C                   endif

     C                   if        $itcwgte = '1'
     C                   eval      $itcwgte = '0'
     C                   endif

     C                   if        $itreore = '1'
     C                   eval      $itreore = '0'
     C                   endif

     C                   if        $itreple = '1'
     C                   eval      $itreple = '0'
     C                   endif

     C                   if        $itrcvde = '1'
     C                   eval      $itrcvde = '0'
     C                   endif

     C                   if        $itflgde = '1'
     C                   eval      $itflgde = '0'
     C                   endif

     C                   if        $itflgbe = '1'
     C                   eval      $itflgbe = '0'
     C                   endif

     C                   if        $itslife = '1'
     C                   eval      $itslife = '0'
     C                   endif

     C                   if        $itndaye = '1'
     C                   eval      $itndaye = '0'
     C                   endif

     C                   if        $ixdsc1e = '1'
     C                   eval      $ixdsc1e = '0'
     C                   endif

     C                   if        $ixdsc2e = '1'
     C                   eval      $ixdsc2e = '0'
     C                   endif

     C                   if        $imtiee = '1'
     C                   eval      $imtiee = '0'
     C                   endif

     C                   if        $imhighe = '1'
     C                   eval      $imhighe = '0'
     C                   endif

     C                   if        $immflge = '1'
     C                   eval      $immflge = '0'
     C                   endif

     C                   if        $imddaye = '1'
     C                   eval      $imddaye = '0'
     C                   endif

     C                   if        $imudaye = '1'
     C                   eval      $imudaye = '0'
     C                   endif

     C                   if        $immdaye = '1'
     C                   eval      $immdaye = '0'
     C                   endif

     C                   if        $imwrnce = '1'
     C                   eval      $imwrnce = '0'
     C                   endif

     C                   if        $imrg1ce = '1'
     C                   eval      $imrg1ce = '0'
     C                   endif

     C                   if        $imrg2ce = '1'
     C                   eval      $imrg2ce = '0'
     C                   endif

     C                   if        $imapcke = '1'
     C                   eval      $imapcke = '0'
     C                   endif

     C                   if        $imnrpke = '1'
     C                   eval      $imnrpke = '0'
     C                   endif

416iAC                   if        $imnslte = '1'
416iAC                   eval      $imnslte = '0'
416iAC                   endif

416iAC                   if        $imxdcke = '1'
416iAC                   eval      $imxdcke = '0'
416iAC                   endif

416iAC                   if        $imbnbre = '1'
416iAC                   eval      $imbnbre = '0'
416iAC                   endif

416iAC                   if        $imbname = '1'
416iAC                   eval      $imbname = '0'
416iAC                   endif

416iAC                   if        $imvname = '1'
416iAC                   eval      $imvname = '0'
416iAC                   endif

416iAC                   if        $imbrnde = '1'
416iAC                   eval      $imbrnde = '0'
416iAC                   endif

416iAC                   if        $imlote  = '1'
416iAC                   eval      $imlote  = '0'
416iAC                   endif

416iAC                   if        $imltrke = '1'
416iAC                   eval      $imltrke = '0'
416iAC                   endif

417 AC                   if        $imodaye = '1'
417 AC                   eval      $imodaye = '0'
417 AC                   endif

500bAC                   if        $ifcate = '1'
500bAC                   eval      $ifcate = '0'
500bAC                   endif

610aAC                   if        $ifodrslote = '1'
610aAC                   eval      $ifodrslote = '0'
610aAC                   endif

640aAC                   if        $ifcaseovfe = '1'
640aAC                   eval      $ifcaseovfe = '0'
640aAC                   endif

640dAC                   if        $ifucicdee = '1'
640dAC                   eval      $ifucicdee = '0'
640dAC                   endif

640dAC                   if        $ifrcvmthe = '1'
640dAC                   eval      $ifrcvmthe = '0'
640dAC                   endif

640dAC                   if        $ifsltmthe = '1'
640dAC                   eval      $ifsltmthe = '0'
640dAC                   endif

640dAC                   if        $ifbrdflge = '1'
640dAC                   eval      $ifbrdflge = '0'
640dAC                   endif

     C                   exsr      cleardefflags

     C                   endsr

     *----------------------------------------------------------------
     *  defcnt   Count existing tie/high definitions.
     *----------------------------------------------------------------

     C     defcnt        begsr

     C                   eval      defcount = 0

     C     keyit         setll     itemdef
     C                   dow       forever = forever
     C     keyit         reade     itemdef                              7879
     C                   if        *in79
     C                   leave
     C                   endif
     C                   eval      defcount = defcount + 1
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  defcpyall  Copy all existing tie/high definitions.
     *----------------------------------------------------------------

     C     defcpyall     begsr

     C     keyitm        setll     itemdef

     C                   dow       forever = forever

     C     keyitm        reade(n)  itemdef                                79
     C                   if        *in79
     C                   leave
     C                   endif

     C                   eval      idwhse = $itwhse
     C                   eval      iditem = $ititem
     C                   write(e)  idrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRADDIDEF'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  defcpylnk  Copy tie/high definitions to linked item.
     *----------------------------------------------------------------

     C     defcpylnk     begsr

     C     keyit         setll     itemdef

     C                   dow       forever = forever

     C     keyit         reade(n)  itemdef                                79
     C                   if        *in79
     C                   leave
     C                   endif

     C                   eval      idwhse = ilwhse
     C                   eval      iditem = ilitem
     C                   write(e)  idrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRADDIDEF'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  defdel   Delete tie/high definition.
     *----------------------------------------------------------------

     C     defdel        begsr

      *  Loop through definitions that were sent.

     C                   eval      curdef = 0
     C                   dou       curdef = %elem($idsdef)

     C                   eval      curdef = curdef + 1

      *    Ignore blank definitions.

     C                   if        $idsdef(curdef) = ' '
     C                   iter
     C                   endif

      *    Try to get existing record.

     C                   eval      kysdef = $idsdef(curdef)
     C     keyid         chain     itemdef                            79

      *    If record not found then there is nothing to do.

     C                   if        *in79
     C                   iter
     C                   endif

      *    Otherwise, delete record.

     C                   delete(e) idrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRDELIDEF'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  defdelall  Delete all existing tie/high definitions.
     *----------------------------------------------------------------

     C     defdelall     begsr

     C     keyit         setll     itemdef

     C                   dow       forever = forever

     C     keyit         reade     itemdef                              7879
     C                   if        *in79
     C                   leave
     C                   endif

     *     If record is locked then send message back and abort.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRDELIDEF'
     C                   eval      $pmessage = 'Lock error on "Delete '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   leave
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   delete(e) idrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRDELIDEF'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   leave
     C                   endif

     C                   enddo

     C                   eval      defcount = 0
     C                   endsr

     *----------------------------------------------------------------
     *  defdellnk  Delete all existing link item tie/high definitions.
     *----------------------------------------------------------------

     C     defdellnk     begsr

     C     keyitl        setll     itemdef

     C                   dow       forever = forever

     C     keyitl        reade     itemdef                              7879
     C                   if        *in79
     C                   leave
     C                   endif

     *     If record is locked then send message back and abort.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRDELIDEF'
     C                   eval      $pmessage = 'Lock error on "Delete '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   leave
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   delete(e) idrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRDELIDEF'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   leave
     C                   endif

     C                   enddo

     C                   eval      defcount = 0
     C                   endsr

     *----------------------------------------------------------------
     *  defrpl   Replace tie/high definition.
     *----------------------------------------------------------------

     C     defrpl        begsr

     C                   exsr      defdelall

     C                   if        not error
     C                   exsr      defupd
     C                   endif

     C                   endsr


     *----------------------------------------------------------------
     *  defrpllnk  Replace tie/high definitions for linked item.
     *----------------------------------------------------------------

     C     defrpllnk     begsr

     C                   exsr      defdellnk

     C                   if        not error
     C                   exsr      defcpylnk
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  defupd   Update (add/change) tie/high definition.
     *----------------------------------------------------------------

     C     defupd        begsr

      *  Get count of existing definitions for item.

     C                   exsr      defcnt

      *  Loop through definitions that were sent.

     C                   eval      curdef = 0
     C                   dou       curdef = %elem($idsdef)

     C                   eval      curdef = curdef + 1

      *    Ignore blank definitions.

     C                   if        $idsdef(curdef) = ' ' or
     C                             not $idsdefu(curdef)
     C                   iter
     C                   endif

      *    Try to get existing record.

     C                   eval      kysdef = $idsdef(curdef)
     C     keyid         chain     itemdef                            79

      *    Check for definition overflow.

     C                   if        *in79 and defcount >= %elem($idsdef)
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'DEFADDOVRF'
416aAC                   exsr      getmsg
     C                   leave
     C                   endif

      *    Update definition fields.

     C                   eval      idtie = $idtie(curdef)
     C                   eval      idhigh = $idhigh(curdef)
     C                   eval      idum   = 'N'
     C                   if        $idpref(curdef) <> 'Y' and
     C                             $idpref(curdef) <> ' '
     C                   eval      idpref = ' '
     C                   else
     C                   eval      idpref = $idpref(curdef)
     C                   endif

      *    Create/Update definition.

     C                   if        *in79
     C                   eval      idwhse = $itwhse
     C                   eval      iditem = $ititem
     C                   eval      idsdef = $idsdef(curdef)
     C                   write(e)  idrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRADDIDEF'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   endif
     C                   else
     C                   update(e) idrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $idsdef(curdef) = '1'
     C                   eval      $preturn = 'ERRUPDIDEF'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Item Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(idwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iditem)
     C                                       + '/'
     C                                       + %trim(idsdef)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   endif
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  defvfy   Vefify definition codes.
     *----------------------------------------------------------------

     C     defvfy        begsr

     *  Clear error flags.

     C                   exsr      cleardefflags

      *  Loop through definitions that were sent.

     C                   eval      curdef = 0
     C                   dou       curdef = %elem($idsdef)

     C                   eval      curdef = curdef + 1

      *    Ignore blank definitions.

     C                   if        $idsdef(curdef) = ' ' or
     C                             not $idsdefu(curdef)
     C                   iter
     C                   endif

      *    Verify definition exists.

     C                   eval      $vsdef = $idsdef(curdef)
     C                   call(e)   'VFYSDEF'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itwhse       $vwhse
     C                   parm                    $vsdef
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $idsdefe(curdef) = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYSDEF'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   leave

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $idsdefe(curdef) = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   leave

     C                   endsl

      *    Tie value cannot be negative.

     C                   if        $idtie(curdef) < 0
     C                   eval      error = *on
     C                   eval      $idtiee(curdef) = '1'
     C                   eval      $preturn = 'NEGATIVTIE'
416aAC                   exsr      getmsg
     C                   leave
     C                   endif

      *    High value cannot be negative.

     C                   if        $idhigh(curdef) < 0
     C                   eval      error = *on
     C                   eval      $idhighe(curdef) = '1'
     C                   eval      $preturn = 'NEGATIVHI'
416aAC                   exsr      getmsg
     C                   leave
     C                   endif

      *    Verify preferred flag.

     C                   if        $idpref(curdef) <> ' ' and
     C                             $idpref(curdef) <> 'Y' and
     C                             $idpref(curdef) <> 'N'
     C                   eval      error = *on
     C                   eval      $idprefe(curdef) = '1'
     C                   eval      $preturn = 'INVLDPREF'
416aAC                   exsr      getmsg
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  deleteitem   Delete item records
     *----------------------------------------------------------------

     C     deleteitem    begsr
     C                   eval      error = *off

     *  Get item.

     C                   eval      lock = *off
     C                   exsr      getitem
     C                   if        error
     C                   goto      enddel
     C                   endif
700dA /free
700dA    // Cannot delete if branded item exist in ITEMBRD
700dA    exec sql select * into :ibrec
700dA             from itembrd
700dA             where ibwhse = :$itWhse and ibbitm = :$itItem;

700dA    if sqlstt = sqlSuccess;
700dA      error = *on;
700dA      $preturn = 'BRDNOTALOW';
700dA      exsr getmsg;
700dA      leavesr;
700dA    endif;
700dA /end-free

     *  Cannot delete if link record exists.

     C     keyit         setll     itemlnk1
     C                   if        %equal
     C                   eval      error = *on
     C                   eval      $preturn = 'DELLNKEXST'
416aAC                   exsr      getmsg
     C                   goto      enddel
     C                   endif

     *  Get corresponding base item.

     C                   exsr      getitemb

     *  Get item quantity record for Base item.

     C     keyitb        chain(n)  itemqty                              78

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $preturn = 'DELQTYEXST'
416aAC                   exsr      getmsg
     C                   goto      enddel
     C                   endif

     *  Cannot delete if a quantity exists for item.
417aA*  and if item is normal or breakdown item. Alias, contract
417aA*  and SSB items can be deleted since they have no qty
417aA*  and slot record.

     C                   if        %found
417aAC                   if        ittype <> 'A'
417aAC                             and ittype <> 'C'
417aAC                             and ittype <> 'S'
510dDC**                           and ittype <> 'R'

     C                   if        iqstk1 <> 0  or
     C                             iqstk2 <> 0  or
     C                             iqstk3 <> 0  or
     C                             iqalc1 <> 0  or
     C                             iqalc2 <> 0  or
     C                             iqalc3 <> 0  or
     C                             iqhld1 <> 0  or
     C                             iqhld2 <> 0  or
     C                             iqhld3 <> 0  or
     C                             iqtri1 <> 0  or
     C                             iqtri2 <> 0  or
     C                             iqtri3 <> 0  or
     C                             iqtro1 <> 0  or
     C                             iqtro2 <> 0  or
     C                             iqtro3 <> 0  or
     C                             iqord1 <> 0
     C                   eval      error = *on
     C                   eval      $preturn = 'DELQTYEXST'
416aAC                   exsr      getmsg
     C                   goto      enddel
     C                   endif
417aAC                   endif
     C                   endif

     *  Skip actual delete for *VERIFY.

416bMC                   if        $psubcmd = '*VERIFYDEL'
     C                   goto      enddel
     C                   endif

     *  Delete item quantity record.

     *    Don't do delete for 'A' and 'S' items

     C                   if        ittype <> 'A'  and
     C                             ittype <> 'S'

     *    Get and lock item quantity record.

     C     keyit         chain     itemqty                              78

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $preturn = 'DELQTYEXST'
416aAC                   exsr      getmsg
     C                   goto      enddel
     C                   endif

     C                   delete(e) iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELIQTY'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Qty" command '
     C                                       + '('
     C                                       + %Trim(%editc(iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iqitem)
     C                                       + ')'
     C                                       + '-' + f6messageid
     C                   goto      enddel
     C                   endif

     C                   endif

     *  Delete UPC records.

     C     keyit         setll     upc1

     C                   dow       forever = forever

     C     keyit         reade     upc1                                 7879
     C                   if        *in79
     C                   leave
     C                   endif

     *     If record is locked then send message back and abort.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $itupce = '1'
     C                   eval      $preturn = 'ERRDELUPC'
     C                   eval      $pmessage = 'Lock error on "Delete '
     C                                       + 'UPC" command '
     C                                       + '('
     C                                       + %Trim(%editc(upwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(upitem)
     C                                       + '/'
     C                                       + %trim(upupc)
     C                                       + ')'
     C                                       + '-' + f7messageid
     C                   goto      enddel
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   delete(e) uprec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $itupce = '1'
     C                   eval      $preturn = 'ERRDELUPC'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'UPC" command '
     C                                       + '('
     C                                       + %Trim(%editc(upwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(upitem)
     C                                       + '/'
     C                                       + %trim(upupc)
     C                                       + ')'
     C                                       + '-' + f7messageid
     C                   goto      enddel
     C                   endif

     C                   enddo

     *  Delete ITEMDEF records.

     C                   exsr      defdelall

     *  Delete ITEMDSC extended description rec.

     C     keyit         chain     itemdsc
     C                   if        %found
     C                   delete(e) ixrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELIDSC'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Desc" command '
     C                                       + '('
     C                                       + %Trim(%editc(ixwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ixitem)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      enddel
     C                   endif
     C                   endif

     *  Delete ITEMMSC misc record

     C     keyit         chain     itemmsc
     C                   if        %found
     C                   delete(e) imrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELIMSC'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Misc" command '
     C                                       + '('
     C                                       + %Trim(%editc(imwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(imitem)
     C                                       + ')'
     C                                       + '-' + f5messageid
     C                   goto      enddel
     C                   endif
     C                   endif
510 A
510 A*  Delete ITEMEXT1 misc record
510 A
510 AC     keyit         chain     itemext1
510 AC                   if        %found
510 AC                   delete(e) ikrec
510 AC                   if        %error
510 AC                   eval      error = *on
510 AC                   eval      $preturn = 'ERRDELIEXT'
510 AC                   eval      $pmessage = 'Error on "Delete '
510 AC                                       + 'Item Ext." command '
510 AC                                       + '('
510 AC                                       + %Trim(%editc(ikwhse:'Z'))
510 AC                                       + '/'
510 AC                                       + %trim(ikitem)
510 AC                                       + ')'
510 AC                                       + '-' + f5messageid
510 AC                   goto      enddel
510 AC                   endif
510 AC                   endif
500bA
500bA*  Delete ITEMFLD misc record
500bA
610bDC**   keyit         chain     itemfld
610bDC**                 if        %found
610bDC**                 delete(e) ifrec
610bDC**                 if        %error
610bDC**                 eval      error = *on
610bAC                   eval      kyWhse = $itwhse
610bAC                   eval      kyItem = $ititem
610bAC                   exsr      GetItemFld
610bAC                   if        foundItemFld
610bAC                   exsr      DltItemFld
610bAC                   if        error
500bAC                   eval      $preturn = 'ERRDELIFLD'
500bAC                   eval      $pmessage = 'Error on "Delete '
500bAC                                       + 'Item Fld" command '
500bAC                                       + '('
500bAC                                       + %Trim(%editc(ifwhse:'Z'))
500bAC                                       + '/'
500bAC                                       + %trim(ifitem)
500bAC                                       + ')'
500bAC                                       + '-' + f8messageid
500bAC                   goto      enddel
500bAC                   endif
500bAC                   endif
500cA
500cA*  Delete ITEMSLS records.
500cA
500cAC                   if        not %open(itemsls)
500cAC                   open      itemsls
500cAC                   endif
700aA
700aAC                   for       i = 1 to 2
700aA
700aAC                   if        i = 1
700aAC                   eval      dltItem = $ititem
700aAC                   else
700aAC                   eval      dltItem = %trim($ititem) + '*EACH'
700aAC                   endif
500cA
700aDC**   keyit         setll     itemsls
700aMC     keyitdel      setll     itemsls
500cA
500cAC                   dow       forever = forever
500cA
700aDC**   keyit         reade     itemsls                              7879
700aMC     keyitdel      reade     itemsls                              7879
500cAC                   if        *in79
500cAC                   leave
500cAC                   endif
500cA
500cA*     If record is locked then send message back and abort.
500cA
500cAC                   if        *in78
500cAC                   eval      error = *on
500cAC                   eval      $itupce = '1'
500cAC                   eval      $preturn = 'ERRDELSLS'
500cAC                   eval      $pmessage = 'Lock error on "Delete '
500cAC                                       + 'ITEMSLS" command '
500cAC                                       + '('
500cAC                                       + %Trim(%editc(ihwhse:'Z'))
500cAC                                       + '/'
500cAC                                       + %trim(ihitem)
500cAC                                       + ')'
500cAC                                       + '-' + f9messageid
500cAC                   goto      enddel
500cAC                   endif
500cA*
500cA*     Otherwise, delete record.
500cA*
500cAC                   delete(e) ihrec
500cAC                   if        %error
500cAC                   eval      error = *on
500cAC                   eval      $itupce = '1'
500cAC                   eval      $preturn = 'ERRDELSLS'
500cAC                   eval      $pmessage = 'Error on "Delete '
500cAC                                       + 'ITEMSLS" command '
500cAC                                       + '('
500cAC                                       + %Trim(%editc(ihwhse:'Z'))
500cAC                                       + '/'
500cAC                                       + %trim(ihitem)
500cAC                                       + ')'
500cAC                                       + '-' + f9messageid
500cAC                   goto      enddel
500cAC                   endif
500cA
500cAC                   enddo
700aA
700aAC                   endfor
500cA
500cA*  Delete ITEMAVG record
500cA
500cAC                   if        not %open(itemavg)
500cAC                   open      itemavg
500cAC                   endif
700aA
700aAC                   for       i = 1 to 2
700aA
700aAC                   if        i = 1
700aAC                   eval      dltItem = $ititem
700aAC                   else
700aAC                   eval      dltItem = %trim($ititem) + '*EACH'
700aAC                   endif
500cA
700aDC**   keyit         chain     itemavg
700aMC     keyitdel      chain     itemavg
500cAC                   if        %found(itemavg)
500cAC                   delete(e) igrec
500cAC                   if        %error
500cAC                   eval      error = *on
500cAC                   eval      $preturn = 'ERRDELAVG'
500cAC                   eval      $pmessage = 'Error on "Delete '
500cAC                                       + 'Item Avg" command '
500cAC                                       + '('
500cAC                                       + %Trim(%editc(igwhse:'Z'))
500cAC                                       + '/'
500cAC                                       + %trim(igitem)
500cAC                                       + ')'
500cAC                                       + '-' + f10messageid
500cAC                   goto      enddel
500cAC                   endif
500cAC                   endif
700aA
700aAC                   endfor

     *  Delete link record.

     C                   if        ittype = 'A'  or
     C                             ittype = 'B'  or
     C                             ittype = 'C'  or
510bMC                             ittype = 'S'
     C                              or ittype = 'R'
     C     keyit         chain     itemlnk
     C                   if        %found
     C                   delete(e) ilrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELILNK'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item Link" command '
     C                                       + '('
     C                                       + %Trim(%editc(ilwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ilitem)
     C                                       + '/'
     C                                       + %trim(ilitm2)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   goto      enddel
     C                   endif
     C                   endif
     C                   endif

510bM*  Delete KITCOMP record(s).
510aA
510aAC                   if        ittype = 'R'
510bDC**   keykit        chain     kitcomp
510bDC**                 if        %found
510bAC     keyit         setll     kitcomp
510bAC                   dow       forever = forever
510bAC     keyit         reade(e)  kitcomp
510bAC                   if        %eof
510bAC                   leave
510bAC                   endif
510aAC                   delete(e) kcrec
510aAC                   if        %error
510aAC                   eval      error = *on
510aAC                   eval      $preturn = 'ERRDELKITC'
510aAC                   eval      $pmessage = 'Error on "Delete '
510aAC                                       + 'KitComp" command '
510aAC                                       + '('
510aAC                                       + %Trim(%editc(kcwhse:'Z'))
510aAC                                       + '/'
510aAC                                       + %trim(kcitem)
510aAC                                       + ')'
510aAC                                       + '-' + f12messageid
510aAC                   goto      enddel
510aAC                   endif
510bDC**                 endif
650eA
650eA*  Delete Itemlnk for each repack item
650eA
650eAC                   if        ittype = 'R'
650eAC     keyitf        chain     itemlnk
650eAC                   if        %found
650eAC                   delete(e) ilrec
650eAC                   endif
650eAC                   endif
650eA
510bAC                   enddo
510aAC                   endif

650aA*  Delete KITITEM record(s).
650aA
650aAC                   if        ittype = 'R'
650aAC     keyit         setll     kititem
650aAC                   dow       forever = forever
650aAC     keyit         reade(e)  kititem
650aAC                   if        %eof
650aAC                   leave
650aAC                   endif
650aAC                   delete(e) kirec
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRDELKITI'
650aAC                   eval      $pmessage = 'Error on "Delete '
650aAC                                       + 'KitItem" command '
650aAC                                       + '('
650aAC                                       + %Trim(%editc(kiwhse:'Z'))
650aAC                                       + '/'
650aAC                                       + %trim(kiitem)
650aAC                                       + ')'
650aAC                                       + '-' + f12messageid
650aAC                   goto      enddel
650aAC                   endif
650aAC                   enddo
650aAC                   endif

640 A*  Auto verify any slots item occupies.
640 A
640 AC                   if        not %open(slot3)
640 AC                   open      slot3
640 AC                   endif
640 A
640 A*  Get user employee number
640 A
640 AC                   call      'GETUSER'
640 AC                   parm                    #user
640 AC                   parm      0             #whse             3 0
640 AC                   parm      0             #emp#             5 0
640 AC                   parm                    #fnam            15
640 AC                   parm                    #init             1
640 AC                   parm                    #lnam            20
640 AC                   parm                    #whdp             5
640 AC                   parm                    #styp             1
640 AC                   parm                    #shft             6
640 AC                   parm                    #crew             6
640 AC                   parm      0             #nhrs             3 1
640 AC                   parm                    #rtn              8
640 AC                   parm                    e$bpu             1
640 AC                   parm                    e$lng             2
640 A*
640 AC     keyit         setll     slot3
640 AC                   dow       forever = forever
640 AC     keyit         reade     slot3
640 AC                   if        %eof(slot3)
640 AC                   leave
640 AC                   endif
640 AC
640 AC                   eval      slstat = 'Z '
640 AC                   update    slrec3
640 A
640 A*   Call DRISLOT to do zero verification.
640 A
640 AC                   exsr      clr$slot
640 AC                   eval      $saemp#U = *on
640 AC                   eval      $saemp# = #emp#
640 A
640 AC                   eval      $slwhseu = *on
640 AC                   eval      $slwhse  = slwhse
640 AC                   eval      $slwhdpu = *on
640 AC                   eval      $slwhdp  = slWhdp
640 AC                   eval      $sldispu = *on
640 AC                   eval      $sldisp  = sldisp
640 AC                   eval      $saActionU = *on
640 AC                   eval      $saAction = 'ZVF'
640 A
640 AC                   eval      $dricommand = 'DRISLOT'
640 AC                   eval      $drisubcmd  = '%ZEROVFY'
640 AC                   eval      $drisys2upd = 'D'
640aDC**                 exsr      zzzdrimain3
640aMC                   exsr      zzzdrimain2
640 A
640 AC                   if        error
640 AC                   endif
640 A*
640 AC                   enddo

     *  Delete item record.

     C     keyit         chain     piritem
     C                   if        %found
     C                   delete(e) itrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELITEM'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                       + 'Item" command '
     C                                       + '('
     C                                       + %Trim(%editc(itwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(ititem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      enddel
     C                   endif
     C                   endif

     C     enddel        endsr

     *----------------------------------------------------------------
     *  getall   Get all item information.
     *----------------------------------------------------------------

     C     getall        begsr

      *  Initialize data structure

     C                   eval      savever# = $itver#
     C                   eval      svwhse   = $itwhse
     C                   eval      svitem   = $ititem
740cAC                   eval      svsession= $isession
     C                   clear                   $item
416jAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   eval      $itwhse = svwhse
     C                   eval      $ititem = svitem

     C* Get item information

     C                   eval      lock = *off
     C                   exsr      getitem
     C                   if        error
     C                   goto      endgetall
     C                   endif

     C                   eval      $ittype = ittype
     C                   eval      $itdesc = itdesc
     C                   eval      $itpdsc = itpdsc
     C                   eval      $itstyp = itstyp
     C                   eval      $itwhdp = itwhdp
     C                   eval      $itdesg = itdesg
     C                   eval      $itactv = itactv
     C                   eval      $itupc  = itupc
     C                   eval      $itbld  = itbld
     C                   eval      $itven# = itven#
     C                   eval      $itvit# = itvit#
     C                   eval      $itum1  = itum1
     C                   eval      $itum2  = itum2
     C                   eval      $itumq2 = itumq2
     C                   eval      $itflg1 = itflg1
     C                   eval      $itum3  = itum3
     C                   eval      $itumq3 = itumq3
     C                   eval      $itflg2 = itflg2
     C                   eval      $itulen = itulen
     C                   eval      $ituwdt = ituwdt
     C                   eval      $ituhgt = ituhgt
     C                   eval      $itcube = itcube
     C                   eval      $itswgt = itswgt
     C                   eval      $itcwgt = itcwgt
     C                   eval      $itreor = itreor
     C                   eval      $itrepl = itrepl
     C                   eval      $itrcvd = itrcvd
     C                   eval      $itflgd = itflgd
     C                   eval      $itflgb = itflgb
     C                   eval      $itslif = itslif
     C                   eval      $itnday = itnday

     C* Get item link information.

     C     keyit         chain(n)  itemlnk                            79
     C                   if        not *in79
     C                   eval      $itmitem = ilitm2
     C                   eval      $itcitem = ilitm3
     C                   endif

     C* Get item misc. information.

     C     keyit         chain(n)  itemmsc                            79
     C                   if        not *in79
     C                   eval      $imtie  = imtie
     C                   eval      $imhigh = imhigh
     C                   eval      $immflg = immflg
     C                   eval      $imdday = imdday
     C                   eval      $imuday = imuday
     C                   eval      $immday = immday
     C                   eval      $imwrnc = imwrnc
     C                   eval      $imrg1c = imrg1c
     C                   eval      $imrg2c = imrg2c
     C                   eval      $imapck = imapck
     C                   eval      $imnrpk = imnrpk
416iAC                   eval      $imnslt = imnslt
416iAC                   eval      $imxdck = imxdck
416iAC                   eval      $imbnbr = imbnbr
416iAC                   eval      $imbnam = imbnam
416iAC                   eval      $imvnam = imvnam
416iAC                   eval      $imbrnd = imbrnd
416iAC                   eval      $imlot  = imlot
416iAC                   eval      $imltrk = imltrk
417 AC                   eval      $imoday = imoday
     C                   endif
500bA
500bAC* Get item Fld information.
500bA
610bDC**   keyit         chain(n)  itemfld                            79
610bDC**                 if        not *in79
610bAC                   eval      kyWhse = $itwhse
610bAC                   eval      kyItem = $ititem
610bAC                   exsr      GetItemFld
610bAC                   if        foundItemFld
500bAC                   eval      $ifcat  = ifcat
610aAC                   eval      $ifodrslot = ifodrslot
640aAC                   eval      $ifcaseovf = ifcaseovf
640dAC                   eval      $ifucicde = ifucicde
640dAC                   eval      $ifrcvmth = ifrcvmth
640dAC                   eval      $ifsltmth = ifsltmth
640dAC                   eval      $ifbrdflg = ifbrdflg
500bAC                   endif

510aA*    Get KITCOMP and KITITEM records, if 'R' Repack Item
510aA
650bA *    the process has been changed to allow a repack item to be
650bA *    associated with another repack item as a parent.  If a
650bA *    repack item is being sent as a parent the command is sent
650bA *    as GETPARENT from IT116 and this program flips switch
650bA *    parentItem *on so it knows to not load the kit array for the
650bA *    parent repack item and overwrite the existing repack item
650bA *    information currently in the array
650bAc                   if        not parentItem
650aA *    value qusbavl reflects whether the user space was setup before
650aA *    this call to hold the returned array values for KIT Items
650aA *    You can reference IT112 for setup code.  This must be completed
650aA *    before you can get these values returned.  You will then need to
650aA *    process the array upon return (IT116 for reference to process)
510aAC                   if        $ittype = 'R'
650aAc                               and qusbavl = 0
650aAc                                and lookingForS = '0'
510aA
650aDC*    keykit        chain(n)  kitcomp
650aMC     keykii        chain(n)  kititem
510aAC                   if        %found
650aAc                   eval      $kiqty1 = kiqty1
650aAC                   eval      $kiqty2 = kiqty2
650aAC                   eval      $kiqty3 = kiqty3
740cAc                   if        $pprogram = 'M17800G'
740cAc                   eval      $kirptp = kirptp
740cAc                   eval      $kidisp = kidisp
740cAc                   endif
740cAc
740cAc**** cleanup session records for this item
740cA /free
740cA   setll (svsession: svitem) workrpk;
740cA   dow forever = forever;
740cA     reade (svsession: svitem) workrpk;
740cA     if %eof(workrpk);
740cA       leave;
740cA     endif;
740cA     delete aerec;
740cA   enddo;
740cA /end-free
650aA *  add loop for KITITEM information.  Build array for IT112
650aA *  to pass along to IT116 which manages KIT components
650aAc                   eval      nxtItm = 1
650aAc     keykii        setll     kitcomp
650aAc     keykii        reade     kitcomp
650aAc                   dow       not %eof
650aA *  save unit measures for repack item before getting parent item
650aAc                   eval      #rum1 = itum1
650aAc                   eval      #rum2 = itum2
650aAc                   eval      #rum3 = itum3
650aA *  get master item information from kititem field kicitm
650aAc                   eval      #mwhse = $itwhse
650aAc                   eval      #mitem = kccitm
650aAc                   exsr      getitemm
650aA *  setup array informtion
740cAc                   select
740cAc                   when      $pprogram = 'M17800G' and
740cAc                             svsession <> ' '
740cAc                   eval      r_aeitem = kiitem
740cAc                   eval      r_aedelCd = 'G'
740cAc                   eval      r_aesitm2 = kccitm
740cAc                   eval      r_aesqty1 = kcqty1
740cAc                   eval      r_aesum1 = #mum1
740cAc                   eval      r_aesqty2 = kcqty2
740cAc                   eval      r_aesum2 = #mum2
740cAc                   eval      r_aesqty3 = kcqty3
740cAc                   eval      r_aesum3 = #mum3
740cAc                   eval      r_aerptp = kirptp
740cAc                   eval      r_aerqty1 = kiqty1
740cAc                   eval      r_aerum1 = #rum1
740cAc                   eval      r_aerqty2 = kiqty2
740cAc                   eval      r_aerum2 = #rum2
740cAc                   eval      r_aerqty3 = kiqty3
740cAc                   eval      r_aerum3 = #rum3
740cAc                   eval      r_aedisp = kidisp
740cAc                   eval      r_aesdisp = kcdisp
740cAc                   eval      r_aesessid = svsession
740cAc                   write     aerec
740cAc                   other
650aAc                   eval      aeitem(nxtItm) = kiitem
650aAc                   eval      aedelCd(nxtItm) = 'G'
650aAc                   eval      aesitm2(nxtItm) = kccitm
650aAc                   eval      aesqty1(nxtItm) = kcqty1
650aAc                   eval      aesum1(nxtItm) = #mum1
650aAc                   eval      aesqty2(nxtItm) = kcqty2
650aAc                   eval      aesum2(nxtItm) = #mum2
650aAc                   eval      aesqty3(nxtItm) = kcqty3
650aAc                   eval      aesum3(nxtItm) = #mum3
650aAc                   eval      aerptp(nxtItm) = kirptp
650aAc                   eval      aerqty1(nxtItm) = kiqty1
650aAc                   eval      aerum1(nxtItm) = #rum1
650aAc                   eval      aerqty2(nxtItm) = kiqty2
650aAc                   eval      aerum2(nxtItm) = #rum2
650aAc                   eval      aerqty3(nxtItm) = kiqty3
650aAc                   eval      aerum3(nxtItm) = #rum3
650aAc                   eval      aearyrec(nxtItm) = nxtItm
650aAc                   eval      aedisp(nxtItm) = kidisp
650aAc                   eval      aesdisp(nxtItm) = kcdisp
650aAc                   eval      nxtItm = nxtItm + 1
740cAc                   endsl
650aAc     keykii        reade     kitcomp
650aAc                   enddo
650aA *  reset PIRITEM record format to original item versus parent itm
650aAc                   exsr      getitem
650aDC*                  eval      $kcqty1 = kcqty1
650aDC*                  eval      $kcqty2 = kcqty2
650aDC*                  eval      $kcqty3 = kcqty3
510aAC                   endif
510aA
510aAC                   endif
650bAc                   endif
     C* If only getting main information, skip to end.

     C                   if        $psubcmd = '*GETMAIN'
     C                   goto      endgetall
     C                   endif

     C* Get extended description.

     C     keyit         chain(n)  itemdsc                            79
     C                   if        not *in79
     C                   eval      $ixdsc1 = ixdsc1
     C                   eval      $ixdsc2 = ixdsc2
     C                   endif

     C* Get tie/high definitions.

     C     keyit         setll     itemdef
     C                   eval      curdef = 0

640cDC*                  dow       forever = forever or
640cMC                   dow       curdef < %elem($idsdef)
640cDC*                            curdef = %elem($idsdef)

     C     keyit         reade(n)  itemdef                                79
     C                   if        *in79
     C                   leave
     C                   endif

     C                   eval      curdef = curdef + 1

     C                   eval      $idsdef(curdef) = idsdef
     C                   eval      $idtie(curdef) = idtie
     C                   eval      $idhigh(curdef) = idhigh
     C                   eval      $idum(curdef) = idum
     C                   eval      $idpref(curdef) = idpref

     C                   enddo

     C     endgetall     endsr

416dA*----------------------------------------------------------------
416dA*  getbase  Get base (parent/master) item for item sent.
416dA*----------------------------------------------------------------
416dA
416dAC     getbase       begsr

     *  Get "sent" item information.

     C                   exsr      verify
     C                   if        error
     C                   goto      endgetbase
     C                   endif

     *  Get base (master) item information.

600bAC                   if        $itmitem <> ' '
     C                   eval      $ititem = $itmitem
     C                   exsr      verify
     C                   if        error
     C                   goto      endgetbase
     C                   endif
600bAC                   endif

     C     endgetbase    endsr

     *----------------------------------------------------------------
     *  getitem  Get PIRITEM record for main item.
     *----------------------------------------------------------------

     C     getitem       begsr

     C* Get item information

     C                   if        lock
     C     keyit         chain     piritem
     C                   else
     C     keyit         chain(n)  piritem
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'INVLDITEM'
416aAC                   exsr      getmsg
     C                   goto      endgetitem
     C                   endif

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  getitemb  Get base item to use for checking ITEMQTY.
     *----------------------------------------------------------------

     C     getitemb      begsr

     *  Initialize base item info with current item.

     C                   eval      #bwhse = itwhse
     C                   eval      #bitem = ititem

     *  If Alias or SSB Item
     *   Then get Base item.

     C                   if        ittype = 'A'  or
     C                             ittype = 'S'

     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getitemc  Get PIRITEM record for contract base item.
     *----------------------------------------------------------------

     C     getitemc      begsr

     *  Get item.

     C                   if        lock
     C     keyitc        chain     piritem                            79
     C                   else
     C     keyitc        chain(n)  piritem
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDCITEM'
416aAC                   exsr      getmsg
     C                   goto      endgetitemc
     C                   endif

     *  Save fields.

     C                   eval      #cwhse = itwhse
     C                   eval      #citem = ititem
     C                   eval      #cdesc = itdesc
     C                   eval      #ctype = ittype

     C     endgetitemc   endsr

     *----------------------------------------------------------------
     *  getitemm  Get PIRITEM record for master item.
     *----------------------------------------------------------------

     C     getitemm      begsr

     *  Get item.

     C                   if        lock
     C     keyitm        chain     piritem                            79
     C                   else
     C     keyitm        chain(n)  piritem
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDMITEM'
416aAC                   exsr      getmsg
     C                   goto      endgetitemm
     C                   endif

     *  Save fields.

     C                   eval      #mwhse = itwhse
     C                   eval      #mitem = ititem
     C                   eval      #mdesc = itdesc
     C                   eval      #mtype = ittype
     C                   eval      #mum1  = itum1
     C                   eval      #mum2  = itum2
650aAC                   eval      #mum3  = itum3
     C                   eval      #mumq2 = itumq2

     C     endgetitemm   endsr

417cA*----------------------------------------------------------------
417cA*  getitemmfg  Get next PIRITEM record for mfg item number.
417cA*
417cA*    Do a READE looking for the next item for the mfg item.
417cA*    Since the key is only whse/mfg, read records looking for
417cA*    the last item read (sent in $ititem). Then get the next
417cA*    record, if any.
417cA*
417cA*----------------------------------------------------------------
417cA
417cAC     getitemmfg    begsr
     C                   eval      error = *off

     C                   if        $ititem = ' '
     C                   eval      found = *on
     C                   else
     C                   eval      found = *off
     C                   endif

     C     keyit4        setll     piritem4

     C                   dow       forever =  forever
     C     keyit4        reade     piritem4

     C                   if        %eof
     C                   eval      $preturn = 'EOF'
     C                   leave
     C                   endif

     C                   if        found
     C                   leave
     C                   endif

     C                   if        ititem = $ititem
     C                   eval      found = *on
     C                   endif

     C                   iter

     C                   enddo

     C     endgetitemmfg endsr

416dA*----------------------------------------------------------------
416dA*  getslot  Get slot item for item sent.
416dA*----------------------------------------------------------------
416dA
416dAC     getslot       begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Save incoming info.

     C                   eval      savesubcmd2 = $psubcmd
     C                   eval      svitem      = $ititem

     *  Change subcommand for use with verify routine.

     C                   eval      $psubcmd = '*VERIFYS'

     *  Get "sent" item information.

     C                   exsr      verify
     C                   if        not error or
     C                             error and $preturn <> 'NOTSLTITM'
     C                   goto      endgetslot
     C                   endif

     *  Loop until slot item is found.

     C                   dow       $ititeme = '1'

     *    See if master item found.

     C                   if        $itmitem = ' '
     C                   eval      $ititem  = svitem
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'SITMNOTFND'
     C                   exsr      getmsg
     C                   leave
     C                   endif

     *    Clear error info.

     C                   eval      $ititeme = '0'
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *    Get master item information.

     C                   eval      $ititem = $itmitem
     C                   exsr      verify
417dDC**                 if        error
417dMC                   if        error and $preturn <> 'NOTSLTITM'
     C                   eval      $ititem  = svitem
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'SITMNOTFND'
     C                   exsr      getmsg
     C                   leave
     C                   endif

     C                   enddo

     *  Restore subcommand

     C                   eval      $psubcmd = savesubcmd2

     C     endgetslot    endsr

416dA*----------------------------------------------------------------
416dA*  getssb   Get corresponding SSB item for item sent.
416dA*----------------------------------------------------------------
416dA
416dAC     getssb        begsr

     *  Save incoming info.

417bDC**                 eval      svitem      = $ititem
417bMC                   eval      svitem2     = $ititem

     *  Loop through linked items for sent item.

     C     keyit         setll     itemlnk1
     C                   dow       forever = forever

417bDC**                 eval      $ititem  = svitem
417bMC                   eval      $ititem  = svitem2
     C     keyit         reade     itemlnk1
     C                   if        %eof
417bDC**                 eval      $ititem  = svitem
417bMC                   eval      $ititem  = svitem2
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'SSBNOTFND'
     C                   exsr      getmsg
     C                   leave
     C                   endif

     *    Get item information.

     C                   eval      $ititem = ilitem
650aAC                   eval      lookingForS = '1'
     C                   exsr      verify
     C                   if        error
417bDC**                 eval      $ititem  = svitem
417bMC                   eval      $ititem  = svitem2
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'SSBNOTFND'
     C                   exsr      getmsg
     C                   leave
     C                   endif

     *    Get out if SSB item is found.

     C                   if        $ittype = 'S'
     C                   leave
     C                   endif

     C                   enddo

     C     endgetssb     endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr

     C                   select

     C                   when      $preturn = 'BLANKDESC'
     C                   eval      $pmessage = 'Description cannot be blank'

     C                   when      $preturn = 'BLANKXDSC'
     C                   eval      $pmessage = 'Description cannot be blank'

     C                   when      $preturn = 'BRKNOTDEF'
     C                   eval      $pmessage = 'Breakdown not defined'
     C                                       + 'for base item'

     C                   when      $preturn = 'CMSTNOTALW'
     C                   eval      $pmessage = 'Contract base item not '
     C                                       + 'allowed. Master must be '
     C                                       + 'Breakdown'

     C                   when      $preturn = 'CMSTNOTCON'
     C                   eval      $pmessage = 'Contract base item not '
     C                                       + 'allowed. Item must be type '
     C                                       + 'Contract.'

     C                   when      $preturn = 'CMSTNOTSNT'
     C                   eval      $pmessage = 'Contract base item must be '
     C                                       + 'sent if master is type '
     C                                       + 'Breakdown'

     C                   when      $preturn = 'DEFADDOVRF'
     C                   eval      $pmessage = 'Cannot add tie/high '
     C                                       + 'definition because '
     C                                       + 'max qty exists'

     C                   when      $preturn = 'DELLNKEXST'
     C                   eval      $pmessage = 'Cannot delete item - '
     C                                       + 'Linked item exists'

     C                   when      $preturn = 'DELQTYEXST'
     C                   eval      $pmessage = 'Cannot delete item - '
     C                                       + 'Quantity exists'

     C                   when      $preturn = 'FLDNOTALWD'
     C                   eval      $pmessage = 'Field '
     C                                       + %trim(field) + ' '
     C                                       + 'not allowed for Alias, '
     C                                       + 'SSB or Contract item.'

     C                   when      $preturn = 'INVLDBFLAG'
     C                   eval      $pmessage = 'Invalid bulk pick flag '
     C                                       + '(' + $itflgb + ')'

     C                   when      $preturn = 'INVLDBKFL1'
     C                   eval      $pmessage = 'Invalid allow breakdown 1 '
     C                                       + 'sale flag '
     C                                       + '(' + $itflg1 + ')'

     C                   when      $preturn = 'INVLDBKFL2'
     C                   eval      $pmessage = 'Invalid allow breakdown 2 '
     C                                       + 'sale flag '
     C                                       + '(' + $itflg2 + ')'

     C                   when      $preturn = 'INVLDCITEM'
     C                   eval      $pmessage = 'Invalid contract base item '
     C                                       + '(' + %trim($itcitem) + ')'

     C                   when      $preturn = 'INVLDCWFLG'
     C                   eval      $pmessage = 'Invalid catch weight flag '
     C                                       + '(' + $itcwgt + ')'

     C                   when      $preturn = 'INVLDDDAY'
     C                   eval      $pmessage = 'Invalid distributor '
     C                                       + 'days to sell '
     C                                       + '('
     C                                       + %Trim(%editc($imdday:'L'))
     C                                       + ')'

     C                   when      $preturn = 'INVLDDFLAG'
     C                   eval      $pmessage = 'Invalid date sensitive '
     C                                       + 'flag '
     C                                       + '(' + $itflgd + ')'

     C                   when      $preturn = 'INVLDI&M'
     C                   eval      $pmessage = 'Invalid item/master '
     C                                       + 'combination '
     C                                       + '('
     C                                       + %trim($ititem)
     C                                       + '/'
     C                                       + %trim($itmitem)
     C                                       + ')'

     C                   when      $preturn = 'INVLDITEM'
     C                   eval      $pmessage = 'Invalid item number '
     C                                       + '('
     C                                       + %trim($ititem)
     C                                       + ')'

640dDC*                  when      $preturn = 'INVLDLFLAG'
640dMC                   when      $preturn = 'INVLDLFLG'
416iAC                   eval      $pmessage = 'Invalid Lot Code item '
416iAC                                       + 'flag '
416iAC                                       + '(' + $imlot + ')'

416iAC                   when      $preturn = 'INVLDLTFLG'
500 DC**                 eval      $pmessage = 'Invalid License Tracking '
500 MC                   eval      $pmessage = 'Invalid Tracking '
416iAC                                       + 'flag '
416iAC                                       + '(' + $imltrk + ')'

500aAC                   when      $preturn = 'INVLDLTFL2'
600aMC                   eval      $pmessage = 'Only Tracking Levels '
720cDC*                                      + '"L", "M" and "H" '
720cMC                                       + '"L", "M" , "H" and "U" '
720cDC*                                      + 'are allowed at this time.'
720cMC                                       + 'are allowed'

ADFbAC                   when      $preturn = 'INVLDLTFL3'
ADFbAC                   eval      $pmessage = 'UCI Tracking is not a'
ADFbMC                                       + 'llowed at this time.'

     C                   when      $preturn = 'INVLDMAPCK'
     C                   eval      $pmessage = 'Invalid auto assign pick '
     C                                       + 'slot flag '
     C                                       + '(' + $imapck + ')'

     C                   when      $preturn = 'INVLDMFLAG'
     C                   eval      $pmessage = 'Invalid manufacturer date '
     C                                       + 'flag '
     C                                       + '(' + $immflg + ')'

     C                   when      $preturn = 'INVLDMITEM'
     C                   eval      $pmessage = 'Invalid master item '
     C                                       + 'number '
     C                                       + '('
     C                                       + %trim($itmitem)
     C                                       + ')'

     C                   when      $preturn = 'INVLDMTYPA'
     C                   eval      $pmessage = 'For Alias item, master '
     C                                       + 'must be type Normal, '
     C                                       + 'Breakdown or SSB'

     C                   when      $preturn = 'INVLDMTYPB'
     C                   eval      $pmessage = 'For breakdown item, master '
     C                                       + 'must be type Normal'

     C                   when      $preturn = 'INVLDMTYPC'
     C                   eval      $pmessage = 'For Contract item, master '
     C                                       + 'must be type Normal or '
     C                                       + 'Breakdown'

510bAC                   when      $preturn = 'INVLDMTYPR'
510bAC                   eval      $pmessage = 'For repack item, master '
510bAC                                       + 'must be type Normal'

     C                   when      $preturn = 'INVLDMTYPS'
     C                   eval      $pmessage = 'For SSB item, master '
     C                                       + 'must be type Normal or '
     C                                       + 'Breakdown'

     C                   when      $preturn = 'INVLDMWRNC'
     C                   eval      $pmessage = 'Invalid catch weight '
     C                                       + 'warning flag '
     C                                       + '(' + $imwrnc + ')'

416iAC                   when      $preturn = 'INVLDNSFLG'
416iAC                   eval      $pmessage = 'Invalid Non-Slotted item '
416iAC                                       + 'flag '
416iAC                                       + '(' + $imnslt + ')'

     C                   when      $preturn = 'INVLDPREF'
     C                   eval      $pmessage = 'Invalid preference option '
     C                                       + '(' + $idpref(curdef) + ')'

     C                   when      $preturn = 'INVLDRG12'
     C                   eval      $pmessage = 'Low variance '
     C                                       + '('
     C                                       + %Trim(%editc($imrg1c:'L'))
     C                                       + ') '
     C                                       + 'must be <= to high '
     C                                       + 'variance '
     C                                       + '('
     C                                       + %Trim(%editc($imrg2c:'L'))
     C                                       + '). '

     C                   when      $preturn = 'INVLDRG1C'
     C                   eval      $pmessage = 'Invalid low catch weight '
     C                                       + 'variance. '
     C                                       + '('
     C                                       + %Trim(%editc($imrg1c:'L'))
     C                                       + '). '
     C                                       + 'Must 0-75 or 99'

     C                   when      $preturn = 'INVLDRG2C'
     C                   eval      $pmessage = 'Invalid high catch weight '
     C                                       + 'variance. '
     C                                       + '('
     C                                       + %Trim(%editc($imrg2c:'L'))
     C                                       + '). '
     C                                       + 'Must 0-75 or 99'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'INVLDSLDAY'
     C                   eval      $pmessage = 'Invalid manufacturer '
     C                                       + 'shelf life days '
     C                                       + '('
     C                                       + %Trim(%editc($immday:'L'))
     C                                       + ')'

     C                   when      $preturn = 'INVLDTYPCG'
     C                   eval      $pmessage = 'Cannot change item type '
     C                                       + 'from "'
     C                                       + ittype
     C                                       + '" to "'
     C                                       + $ittype
     C                                       + '"'

     C                   when      $preturn = 'INVLDUDAY'
     C                   eval      $pmessage = 'Invalid user '
     C                                       + 'days to sell '
     C                                       + '('
     C                                       + %Trim(%editc($imuday:'L'))
     C                                       + ')'

416iAC                   when      $preturn = 'INVLDXDFLG'
416iAC                   eval      $pmessage = 'Invalid Crossdock item '
416iAC                                       + 'flag '
416iAC                                       + '(' + $imxdck + ')'

     C                   when      $preturn = 'ITEMEXIST'
     C                   eval      $pmessage = 'Item already exists '
     C                                       + '(' + %trim($ititem) + ') '

     C                   when      $preturn = 'ITMNOTSNT'
     C                   eval      $pmessage = 'Item number was not sent'

640bAC                   when      $preturn = 'LARGECUBE'
640bAC                   eval      $pmessage = 'Dimensions entered are too '
640bAC                                       + 'large for cube'

     C                   when      $preturn = 'MSTITMCHG'
     C                   eval      $pmessage = 'Master item is not allowed '
     C                                       + 'to be changed'

     C                   when      $preturn = 'MSTNOTBLNK'
     C                   eval      $pmessage = 'Master item not allowed'

     C                   when      $preturn = 'MSTNOTSNT'
     C                   eval      $pmessage = 'Master item must be sent'

     C                   when      $preturn = 'MSTNOTSNTC'
     C                   eval      $pmessage = 'Master item must be sent '
     C                                       + 'when changing item type'

416iAC                   when      $preturn = 'NEGATIVB#'
416iAC                   eval      $pmessage = 'Buyer number cannot be '
416iAC                                       + 'negative '
416iAC                                       + '('
416iAC                                       + %Trim(%editc($imbnbr:'L'))
416iAC                                       + ')'

     C                   when      $preturn = 'NEGATIVCUB'
     C                   eval      $pmessage = 'Cube cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($itcube:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVDDY'
     C                   eval      $pmessage = 'Distributor days to sell '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($imdday:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVHGT'
     C                   eval      $pmessage = 'Height cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($ituhgt:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVHI'
     C                   eval      $pmessage = 'High value cannot be '
     C                                       + 'negative '
     C                                       + '('
     C                                      + %Trim(%editc($idhigh(curdef):'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVLEN'
     C                   eval      $pmessage = 'Length cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($itulen:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVMDY'
     C                   eval      $pmessage = 'Mfg shelf life days '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($immday:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVMHI'
     C                   eval      $pmessage = 'Mfg high value '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($imhigh:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVMTI'
     C                   eval      $pmessage = 'Mfg tie value '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($imtie:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVNDY'
     C                   eval      $pmessage = 'Notice days cannot be '
     C                                       + 'negative '
     C                                       + '('
     C                                       + %Trim(%editc($itnday:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVNPK'
     C                   eval      $pmessage = 'Number of pick slot cannot '
     C                                       + 'be negative '
     C                                       + '('
     C                                       + %Trim(%editc($imnrpk:'L'))
     C                                       + ')'

417 AC                   when      $preturn = 'NEGATIVODY'
417 AC                   eval      $pmessage = 'Days out cannot be '
417 AC                                       + 'negative '
417 AC                                       + '('
417 AC                                       + %Trim(%editc($imoday:'L'))
417 AC                                       + ')'

     C                   when      $preturn = 'NEGATIVRG1'
     C                   eval      $pmessage = 'Catch weight low variance '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($imrg1c:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVRG2'
     C                   eval      $pmessage = 'Catch weight high variance '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($imrg2c:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVRPL'
     C                   eval      $pmessage = 'Replenishment level cannot '
     C                                       + 'be negative '
     C                                       + '('
     C                                       + %Trim(%editc($itrepl:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVSLF'
     C                   eval      $pmessage = 'Shelf life cannot be '
     C                                       + 'negative '
     C                                       + '('
     C                                       + %Trim(%editc($itslif:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVTIE'
     C                   eval      $pmessage = 'Tie value cannot be '
     C                                       + 'negative '
     C                                       + '('
     C                                       + %Trim(%editc($idtie(curdef):'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVUDY'
     C                   eval      $pmessage = 'User days to sell cannot '
     C                                       + 'be negative '
     C                                       + '('
     C                                       + %Trim(%editc($imuday:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVUQ1'
     C                   eval      $pmessage = 'Breakdown 1 uom quantity '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($itumq2:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVUQ2'
     C                   eval      $pmessage = 'Breakdown 2 uom quantity '
     C                                       + 'cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($itumq3:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVV#'
     C                   eval      $pmessage = 'Vendor number cannot be '
     C                                       + 'negative '
     C                                       + '('
     C                                       + %Trim(%editc($itven#:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVWDT'
     C                   eval      $pmessage = 'Width cannot be negative '
     C                                       + '('
     C                                       + %Trim(%editc($ituwdt:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVWGT'
     C                   eval      $pmessage = 'Shipping weight cannot be '
     C                                       + 'negative '
     C                                       + '('
     C                                       + %Trim(%editc($itswgt:'L'))
     C                                       + ')'

     C                   when      $preturn = 'NOTSLTITM'
     C                   eval      $pmessage = 'Item not allowed into slot.'
510bDC**                                     + 'Only Normal and Brkdn '
510bAC                                       + 'Only Normal, B and R '
     C                                       + 'allowed.'

     C                   when      $preturn = 'NPKNOTZERO'
     C                   eval      $pmessage = 'Number of pick slots must '
     C                                       + 'be zero for PIR items'

416dAC                   when      $preturn = 'SITMNOTFND'
416dAC                   eval      $pmessage = 'Corresponding slot item '
416dAC                                       + 'not found for item '
416dAC                                       + %trim($ititem)

416dAC                   when      $preturn = 'SSBNOTFND'
416dAC                   eval      $pmessage = 'Corresponding SSB item '
416dAC                                       + 'not found for item '
416dAC                                       + %trim($ititem)

     C                   when      $preturn = 'TYPNOTSNT'
     C                   eval      $pmessage = 'Item type must be sent '
     C                                       + 'when adding an item'

     C                   when      $preturn = 'UM2NOTSNT'
     C                   eval      $pmessage = 'Some of the three Brkdwn1 '
     C                                       + 'fields not sent'

     C                   when      $preturn = 'UM3NOTSNT'
     C                   eval      $pmessage = 'Some of the three Brkdwn2 '
     C                                       + 'fields not sent'

     C                   when      $preturn = 'VARNOTSNT'
     C                   eval      $pmessage = 'One of the catch weight '
     C                                       + 'variances not sent'

610aAC                   when      $preturn = 'WHDNOTSNT'
610aAC                   eval      $pmessage = 'Department must be sent'

     C                   when      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse was not sent'

     C                   when      $preturn = 'ZEROUMQ1'
     C                   eval      $pmessage = 'Brkdwn1 quantity must be '
     C                                       + 'sent when um code is sent'

     C                   when      $preturn = 'ZEROUMQ2'
     C                   eval      $pmessage = 'Brkdwn2 quantity must be '
     C                                       + 'sent when um code is sent'

640dAC                   when      $preturn = 'INVLDBRDF'
640dAC                   eval      $pmessage = 'Brand flag must be Y or N'

640dAC                   when      $preturn = 'INVLDUCI'
700cDC*                  eval      $pmessage = 'UCI Encoding must be 1-5'
700cMC                   eval      $pmessage = 'Invalid UCI Encoding - Use Look'
700cAC                                       + 'up'

720cAC                   when      $preturn = 'INVLDUC1'
720cAC                   eval      $pmessage = 'UCI Encoding Must be 2 '
720cAC                                       + 'for UCI Tracking Item   '

720cAC                   when      $preturn = 'INVLDUC2'
720cAC                   eval      $pmessage = 'Receiving & Selection Method '
720cAC                                       + 'Must be 2 for UCI Tracking Item'

640dAC                   when      $preturn = 'INVLDRCV'
700cDC*                  eval      $pmessage = 'Receiving Method must be 1 or 2'
700cMC                   eval      $pmessage = 'Invalid Receiving Method - Use '
700cAC                                       + 'Lookup'

640dAC                   when      $preturn = 'INVLDRC1'
700cDC*                  eval      $pmessage = 'Receiving Method 2 only valid  '
700cDC*                                      + 'with UCI code 2 or 5     '
700cMC                   eval      $pmessage = 'Receiving Method 2 is Not Valid'
700cMC                                       + ' with UCI Encoding 1     '

ADFaAC                   when      $preturn = 'INVLDRC2'
ADFaMC                   eval      $pmessage = 'Invalid Receiving Method - UCI '
ADFaAC                                       + 'Receiving not allowed'

720bAC                   when      $preturn = 'INVLDRC3'
720bMC                   eval      $pmessage = 'Must sell item by Breakdown UOM'

640dAC                   when      $preturn = 'INVLDSEL'
700cDC*                  eval      $pmessage = 'Selection method must be 1-3   '
700cMC                   eval      $pmessage = 'Invalid Selection Method - Use '
700cAC                                       + 'Lookup'

640dAC                   when      $preturn = 'INVLDSE2'
700cDC*                  eval      $pmessage = 'Selection Method 2 only valid  '
700cDC*                                      + 'with UCI 2 thru 5'
700cMC                   eval      $pmessage = 'Selection Method 2 is Not Valid'
700cMC                                       + ' with UCI Encoding 1     '

650dAC                   when      $preturn = 'INVLDSE3'
650dAC                   eval      $pmessage = 'PTI Selection not allowed on a '
650dAC                                       + 'catch weight item'

650fAC                   when      $preturn = 'INVLDSE4'
650fAC                   eval      $pmessage = 'PTI Selection not allowed with '
650fAC                                       + 'UCI Receiving.'

710aAC                   when      $preturn = 'INVLDSE5'
710aAC                   eval      $pmessage = 'UPCs have not been collected.'

710cAC                   when      $preturn = 'INVLDSE6'
710cAC                   eval      $pmessage = 'Item is not sold as breakdown.'

700dAC                   when      $preturn = 'BRDNOTALOW'
700dAC                   eval      $pmessage = 'Branded Items can only be delet'
700dAC                                       + 'ed with Item Brand Maint.'

740cAC                   when      $preturn = 'REPACK01'
740cAC                   eval      $pmessage = 'Repack Type must be 1 or 2'

740cAC                   when      $preturn = 'REPACK02'
740cAC                   eval      $pmessage = 'On-Demand only valid for '
740cAC                                       + 'Repack Type 2.'

740cAC                   when      $preturn = 'REPACK03'
740cAC                   eval      $pmessage = 'Repack Output Qty '
740cAC                                       + 'must be entered'

740cAC                   when      $preturn = 'REPACK07'
740cAC                   eval      $pmessage = 'At least one component '
740cAC                                       + 'must be entered'

740cAC                   when      $preturn = 'REPACK08'
740cAC                   eval      $pmessage = 'On-Demand slot must be '
740cAC                                       + 'entered for Repack Type 2'

740cAC                   when      $preturn = 'REPACK15'
740cAC                   eval      $pmessage = 'Slot not Valid'

     C                   other
     C                   eval      $pmessage = 'Error occured - '
     C                                       + %Trim($preturn) + ' '
     C                                       + '(Description not available)'

     C                   endsl
     C                   endsr

     *----------------------------------------------------------------
     *  getlink  Get item link record.
     *----------------------------------------------------------------

     C     getlink       begsr

     C* Get item link record

     C                   if        lock
     C     keyil         chain     itemlnk
     C                   else
     C     keyil         chain(n)  itemlnk
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   endif

     C     endgetlink    endsr

650eA*----------------------------------------------------------------
650eA*  getlinkf  Get item link record.
650eA*----------------------------------------------------------------
650eA
650eAC     getlinkf      begsr
650eA
650eAC* Get item link record
650eA
650eAC                   if        lock
650eAC     keyilf        chain     itemlnk
650eAC                   else
650eAC     keyilf        chain(n)  itemlnk
650eAC                   endif
650eA
650eAC                   if        not %found
650eAC                   eval      error = *on
650eAC                   endif
650eA
650eAC     endgetlinkf   endsr
     *----------------------------------------------------------------
     *  Verify      Simple verification.
     *----------------------------------------------------------------

     C     verify        begsr
416gAC                   eval      error = *off

     *  Verify item by doing a *GETMAIN operation.

     C                   eval      savesubcmd = $psubcmd
     C                   eval      $psubcmd = '*GETMAIN'
650bAc                   eval      parentItem = *on
     C                   exsr      getall
650bAc                   eval      parentItem = *off
     C                   eval      $psubcmd = savesubcmd

     *  If item wasn't found, get out.

     C                   if        error
     C                   goto      endvfy
     C                   endif

     *  Otherwise, if *VERIFYS make sure item is correct type.

     C                   if        $psubcmd = '*VERIFYS' and
     C                             $ittype <> ' ' and $ittype <> 'B'
510bAC                             and $ittype <> 'R'
416gAC                   eval      error = *on
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'NOTSLTITM'
     C                   exsr      getmsg
     C                   goto      endvfy
     C                   endif

     C     endvfy        endsr

     *----------------------------------------------------------------
     *  verifyadd   Change verification.
     *----------------------------------------------------------------

     C     verifyadd     begsr
416gAC                   eval      error = *off

     *  Do "Before" general verificaion.

     C                   exsr      verifygen1
     C     error         cabeq     *on           endvfyadd

     *  Item type must be sent.

     C                   if        not $ittypeu
     C                   eval      error = *on
     C                   eval      $ittypee = '1'
     C                   eval      $preturn = 'TYPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Item cannot already exist.

     C                   eval      lock = *off
     C                   exsr      getitem
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'ITEMEXIST'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   other
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endsl

     *  For base item, master item must be blank.

     C                   select

     C                   when      $ittype = ' '
     C                   if        $itmitemu and $itmitem <> ' '
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'MSTNOTBLNK'
416aAC                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Otherwise ...

     C                   other

     *      Master item must be sent

650aA*      Ignore master for Verifyadd when IT112.  IT116 now adding
650aAC                   if        $pprogram='IT112' and $ittype='R'
740cAc                             or $pprogram='M17800U' and
740cAc                                $ittype='R'
650aA*      if coming from IT112 and Repack item then ignore this
650aA*      check since IT116 will now have data for this check
650aAC                   else
     C                   if        not $itmitemu or $itmitem = ' '
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'MSTNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif
650aAC                   endif

     C                   endsl

     *  Verify master item.

     C                   if        $itmitemu and $itmitem <> ' '
     C                   eval      #mwhse = $itwhse
     C                   eval      #mitem = $itmitem
     C                   exsr      checkmitem
     C                   if        error
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  If type is Contract and master item is not Broken case ...
     *    Then contract base item cannot be sent.

     C                   if        $ittype = 'C' and #mtype = ' '
     C                   if        $itcitemu and $itcitem <> ' '
     C                   eval      error = *on
     C                   eval      $itciteme = '1'
     C                   eval      $preturn = 'CMSTNOTALW'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  If type is Contract and master item is Broken case ...
     *    Then contract base item must be sent.

     C                   if        $ittype = 'C' and #mtype = 'B'
     C                   if        not $itcitemu or $itcitem = ' '
     C                   eval      error = *on
     C                   eval      $itciteme = '1'
     C                   eval      $preturn = 'CMSTNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  Verify contract master item.

     C                   if        $itcitemu and $itcitem <> ' '
     C                   eval      lock = *off
     C                   exsr      getitemc
     C                   if        error
     C                   eval      error = *on
     C                   eval      $itciteme = '1'
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  If type is Contract and master item is Broken case ...
     *    Then contract base item must be Contract item.

     C                   if        $ittype = 'C' and #mtype = 'B'
     C                   if        #ctype <> 'C'
     C                   eval      error = *on
     C                   eval      $itciteme = '1'
     C                   eval      $preturn = 'CMSTNOTCON'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  If Mfg date item, check subordinate fields.

     C                   if        $immflg = 'Y'

     *    Force date sensitive flag to 'Y'

VGOa *    Do not force date sensitive flag for Vigo
VGOaAC     client        cabeq     vigo          skipv1
     C                   eval      $itflgdu = *on
     C                   eval      $itflgd = 'Y'
VGOaAC     skipv1        tag

     *    Mfg shelf life days must be > 0.

     C                   if        not $immdayu or
     C                             $immday <= 0
     C                   eval      error = *on
     C                   eval      $immdaye = '1'
     C                   eval      $preturn = 'INVLDSLDAY'
416aAC                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *    Distributor days must be > 0.

CBIaMC                   if        (not $imddayu or
CBIaMC                             $imdday <= 0)
CBIaAC                             and client <> Cheney
CBIaA*
CBIaAC                             or  (client = Cheney)
CBIaAC                             and ($imdday < 0)
CBIaA*
     C                   eval      error = *on
     C                   eval      $imddaye = '1'
     C                   eval      $preturn = 'INVLDDDAY'
416aAC                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *    User days must be > 0.

CBIaMC                   if        (not $imudayu or
CBIaMC                             $imuday <= 0)
CBIaAC                             and client <> Cheney
CBIaA*
CBIaAC                             or  (client = Cheney)
CBIaAC                             and ($imuday < 0)
CBIaA*
     C                   eval      error = *on
     C                   eval      $imudaye = '1'
     C                   eval      $preturn = 'INVLDUDAY'
416aAC                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     C                   endif

     *  Number of pick slots must be zero for PIR item.

     C                   if        $itstyp = 'P'
     C                   if        $imnrpku and $imnrpk <> 0
     C                   eval      error = *on
     C                   eval      $imnrpke = '1'
     C                   eval      $preturn = 'NPKNOTZERO'
416aAC                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif
     C                   endif


740cA*  Number of pick slots must be zero for PIR item.

740cA /free
740cA   if $ittype = 'R' and $pprogram = 'M17800U';
740cA     chain ($isession: $ititem) workrpk;
740cA     if not %found(workrpk);
740cA       error = *on;
740cA       $preturn = 'REPACK07';
740cA       exsr getmsg;
740cA       leavesr;
740cA     endif;
740cA   endif;
740cA /end-free

740cA /free
740cA   if $ittype = 'R' and $pprogram = 'M17800U';
740cA     if $kiqty1u = *on and $kiqty1 = 0;
740cA       error = *on;
740cA       $preturn = 'REPACK03';
740cA       exsr getmsg;
740cA       leavesr;
740cA     endif;
740cA   endif;
740cA /end-free

     *  Do "After" general verificaion.

     C                   exsr      verifygen2

     C     endvfyadd     endsr


     *----------------------------------------------------------------
     *  verifychg   Change verification.
     *----------------------------------------------------------------

     C     verifychg     begsr
416gAC                   eval      error = *off

     *  Do "Before" general verificaion.

     C                   exsr      verifygen1
     C     error         cabeq     *on           endvfychg

     *  Get item info (already retreived in verifygen1 for *BATCHANGE)

     C                   if        $psubcmd <> '*BATCHANGE'
     C                   eval      lock = *off
     C                   exsr      getitem
     C                   if        error
     C                   eval      $ititeme = '1'
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  See if item type is changing and if it is ok to do so.

     C                   if        $ittypeu and
     C                             $ittype <> ittype
     C                   exsr      chktypchg
     C     error         cabeq     *on           endvfychg
     C                   endif

     *  For SSB and Contract items,
     *    make sure that master items have not changed.

     C                   if        $ittypeu and $ittype = 'C' or
     C                             $ittypeu and $ittype = 'S' or
     C                             not $ittypeu and ittype = 'C' or
     C                             not $ittypeu and ittype = 'S'

     C                   if        $itmitemu or
     C                             $itcitemu

     C                   eval      lock = *off
     C                   eval      #lwhse = $itwhse
     C                   eval      #litem = $ititem
     C                   exsr      getlink
     C                   if        error
     C                   eval      error = *off
     C                   else
     C                   if        $itmitemu and $itmitem <> ilitm2 or
     C                             $itcitemu and $itcitem <> ilitm3
     C                   eval      error = *on
     C                   eval      $preturn = 'MSTITMCHG'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif
     C                   endif

     C                   endif
     C                   endif

     *  For certain item type changes, verify master item number.

     C                   if        chgn2b or chga2b

     *      Master item must be sent

     C                   if        not $itmitemu or $itmitem = ' '
     C                   eval      error = *on
     C                   eval      $itmiteme = '1'
     C                   eval      $preturn = 'MSTNOTSNTC'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif

     *      Verify master item

     C                   eval      #mwhse = $itwhse
     C                   eval      #mitem = $itmitem
     C                   exsr      checkmitem
     C                   if        error
     C                   goto      endvfychg
     C                   endif

     C                   endif

     *  If Mfg date item, check subordinate fields.

     C                   if        $immflgu and $immflg = 'Y' or
     C                             not $immflgu and immflg = 'Y'

     *    Force date sensitive flag to 'Y'

     C                   if        $itflgdu and $itflgd <> 'Y' or
     C                             not $itflgdu and itflgd <> 'Y'
     C                   eval      $itflgdu = *on
     C                   eval      $itflgd = 'Y'
     C                   endif

     *    Mfg shelf life days must be > 0.

     C                   if        $immdayu and $immday <= 0 or
     C                             not $immdayu and immday <= 0
     C                   eval      error = *on
     C                   eval      $immdaye = '1'
     C                   eval      $preturn = 'INVLDSLDAY'
416aAC                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif

     *    Distributor days must be > 0.

CBIaMC                   if        ($imddayu and $imdday <= 0 or
CBIaMC                             not $imddayu and imdday <= 0)
CBIaAC                             and client <> Cheney
CBIaA*
CBIaAC                             or  (client = Cheney)
CBIaAC                             and ($imddayu
CBIaAC                             and  $imdday < 0
CBIaAC                             or   not $imddayu
CBIaAC                             and  imdday < 0)
CBIaA*
     C                   eval      error = *on
     C                   eval      $imddaye = '1'
     C                   eval      $preturn = 'INVLDDDAY'
416aAC                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif

     *    User days must be > 0.

CBIaMC                   if        ($imudayu and $imuday <= 0 or
CBIaMC                             not $imudayu and imuday <= 0)
CBIaAC                             and client <> Cheney
CBIaA*
CBIaAC                             or  (client = Cheney)
CBIaAC                             and ($imudayu
CBIaAC                             and  $imuday < 0
CBIaAC                             or   not $imudayu
CBIaAC                             and  imuday < 0)
CBIaA*
     C                   eval      error = *on
     C                   eval      $imudaye = '1'
     C                   eval      $preturn = 'INVLDUDAY'
416aAC                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif

     C                   endif

     *  Number of pick slots must be zero for PIR item.

     C                   if        $itstypu and $itstyp = 'P' or
     C                             not $itstypu and itstyp = 'P'
     C                   if        $imnrpku and $imnrpk <> 0 or
     C                             not $imnrpku and imnrpk <> 0
     C                   eval      error = *on
     C                   eval      $imnrpke = '1'
     C                   eval      $preturn = 'NPKNOTZERO'
416aAC                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif
     C                   endif


740cA*  Number of pick slots must be zero for PIR item.

740cA /free
740cA   if $ittype = 'R' and $pprogram = 'M17800U';
740cA     chain ($isession: $ititem) workrpk;
740cA     if not %found(workrpk);
740cA       error = *on;
740cA       $preturn = 'REPACK07';
740cA       exsr getmsg;
740cA       leavesr;
740cA     endif;
740cA   endif;
740cA /end-free

740cA /free
740cA   if $ittype = 'R' and $pprogram = 'M17800U';
740cA     if $kiqty1u = *on and $kiqty1 = 0;
740cA       error = *on;
740cA       $preturn = 'REPACK03';
740cA       exsr getmsg;
740cA       leavesr;
740cA     endif;
740cA   endif;
740cA /end-free
     *  Do "After" general verificaion.

     C                   exsr      verifygen2

     C     endvfychg     endsr

     *----------------------------------------------------------------
     *  verifygen1  General verification before add/chg verification
     *----------------------------------------------------------------

     C     verifygen1    begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        $itwhse = 0
     C                   eval      error = *on
     C                   eval      $itwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     *  Item must be sent.

     C                   if        $ititem = ' '
     C                   eval      error = *on
     C                   eval      $ititeme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     *  Verify warehouse.

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen1

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $itwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen1

     C                   endsl

     *  Verify item type.

     C                   if        $ittypeu
     C                   call(e)   'VFYITYP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $ittype       $vityp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $ittypee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYITYP'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen1

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $ittypee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen1

     C                   endsl
     C                   endif

     *  If using extended descriptions and extended description sent ...
     *    Then if normal desc is blank or not sent, set it to ext. desc.

     C                   if        opxdsc = 'Y' and $ixdsc1u
     C                   if        not $itdescu or $itdesc = ' '
     C                   eval      $itdescu = *on
     C                   eval      $itdesc  = $ixdsc1
     C                   endif
     C                   endif

     *  For Alias, SSB and Contract items, only the following fields
     *  can be sent:

     *    Warehouse, Item, Type, Descriptions, Master, Contract Master.

     *  Note: For batch updates, we will just ignore the fields.

     C                   if        $psubcmd <> '*BATADD' and
     C                             $psubcmd <> '*BATCHANGE'

     C                   if        $ittype = 'A' or
     C                             $ittype = 'C' or
     C                             $ittype = 'S'

     C                   eval      error = *on
     C                   select
     C                   when      $itstypu
     C                   eval      field = '$itstyp'
     C                   when      $itwhdpu
     C                   eval      field = '$itwhdp'
     C                   when      $itdesgu
     C                   eval      field = '$itdesg'
     C                   when      $itactvu
     C                   eval      field = '$itactv'
     C                   when      $itupcu
     C                   eval      field = '$itupc'
     C                   when      $itbldu
     C                   eval      field = '$itbld'
     C                   when      $itven#u
     C                   eval      field = '$itven#'
     C                   when      $itvit#u
     C                   eval      field = '$itvit#'
     C                   when      $itum1u
     C                   eval      field = '$itum1'
     C                   when      $itum2u
     C                   eval      field = '$itum2'
     C                   when      $itumq2u
     C                   eval      field = '$itumq2'
     C                   when      $itflg1u
     C                   eval      field = '$itflg1'
     C                   when      $itum3u
     C                   eval      field = '$itum3'
     C                   when      $itumq3u
     C                   eval      field = '$itumq3'
     C                   when      $itflg2u
     C                   eval      field = '$itflg2'
     C                   when      $itulenu
     C                   eval      field = '$itulen'
     C                   when      $ituwdtu
     C                   eval      field = '$ituwdt'
     C                   when      $ituhgtu
     C                   eval      field = '$ituhgt'
     C                   when      $itcubeu
     C                   eval      field = '$itcube'
     C                   when      $itswgtu
     C                   eval      field = '$itswgt'
     C                   when      $itcwgtu
     C                   eval      field = '$itcwgt'
     C                   when      $itreoru
     C                   eval      field = '$itreor'
     C                   when      $itreplu
     C                   eval      field = '$itrepl'
     C                   when      $itrcvdu
     C                   eval      field = '$itrcvd'
     C                   when      $itflgdu
     C                   eval      field = '$itflgd'
     C                   when      $itflgbu
     C                   eval      field = '$itflgb'
     C                   when      $itslifu
     C                   eval      field = '$itslif'
     C                   when      $itndayu
     C                   eval      field = '$itnday'
     C                   when      $imtieu
     C                   eval      field = '$imtie'
     C                   when      $imhighu
     C                   eval      field = '$imhigh'
     C                   when      $immflgu
     C                   eval      field = '$immflg'
     C                   when      $imddayu
     C                   eval      field = '$imdday'
     C                   when      $imudayu
     C                   eval      field = '$imuday'
     C                   when      $immdayu
     C                   eval      field = '$immday'
     C                   when      $imwrncu
     C                   eval      field = '$imwrnc'
     C                   when      $imrg1cu
     C                   eval      field = '$imrg1c'
     C                   when      $imrg2cu
     C                   eval      field = '$imrg2c'
     C                   when      $imapcku
     C                   eval      field = '$imapck'
     C                   when      $imnrpku
     C                   eval      field = '$imnrpk'
     C                   other
     C                   eval      error = *off
     C                   endsl

     C                   if        error
     C                   eval      $preturn = 'FLDNOTALWD'
416aAC                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     C                   eval      curdef = 0
     C                   dou       curdef = %elem($idsdef)
     C                   eval      curdef = curdef + 1

     C                   if        $idsdefu(curdef)
     C                   eval      error = *on
     C                   eval      field = '$idsdef('
     C                                       + %Trim(%editc(curdef:'L'))
     C                                   + ')'
     C                   eval      $preturn = 'FLDNOTALWD'
416aAC                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     C                   enddo

     C                   endif
     C                   endif

     *  For batch operations, see if item exists.

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C
     C                   eval      lock = *off
     C                   exsr      getitem
     C
     C                   select

     *    If item doesn't exist, change *BATCHANGE to *BATADD.

     C                   when      error
     C                   eval      error = *off
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   if        $psubcmd = '*BATCHANGE'
     C                   eval      $psubcmd = '*BATADD'
     C                   endif

     *    If item does exist, change *BATADD to *BATCHANGE.

     C                   other
     C                   if        $psubcmd = '*BATADD'
     C                   eval      $psubcmd = '*BATCHANGE'
     C                   endif
     C
     C                   endsl
     C
     C                   endif

     C     endvfygen1    endsr

     *----------------------------------------------------------------
     *  verifygen2  General verification after add/chg verification
     *----------------------------------------------------------------

     C     verifygen2    begsr

     *  Verify description.

     C                   if        opxdsc = 'N' and
     C                             $itdescu and $itdesc = ' '
     C                   eval      error = *on
     C                   eval      $itdesce = '1'
     C                   eval      $preturn = 'BLANKDESC'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   if        opxdsc = 'Y' and
     C                             $ixdsc1u and $ixdsc1 = ' '
     C                   eval      error = *on
     C                   eval      $ixdsc1e = '1'
     C                   eval      $preturn = 'BLANKXDSC'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify warehouse department.

     C                   if        $itwhdpu
     C                   call(e)   'VFYWHDP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itwhse       $vwhse
     C                   parm      $itwhdp       $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itwhdpe = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHDP'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $itwhdpe = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif

     *  Verify section type.

     C                   if        $itstypu
     C                   call(e)   'VFYSTYP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itstyp       $vstyp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itstype = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYSTYP'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $itstype = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif
500bA
500bA*  Verify item category.
500bA
500bAC                   if        $ifcatu
500bAC                   call(e)   'VFYICAT'
500bAC                   parm      '*VERIFY'     $vcommand
500bAC                   parm      '*NONE'       $vprg
500bAC                   parm      $ifcat        $vcat
500bAC                   parm      ' '           $vdesc
500bAC                   parm      ' '           $vreturn
500bAC                   parm      ' '           $vmessage
500bAC                   parm      ' '           $vmsgk
500bA
500bAC                   select
500bAC                   when      %error
500bAC                   eval      error = *on
500bAC                   eval      $ifcate = '1'
500bAC                   eval      $preturn  = 'CALLERROR'
500bAC                   eval      $pmessage = 'Error occured on call to '
500bAC                                       + 'VFYICAT'
500bAC                                       + '/' + %trim($vcommand)
500bAC                                       + ' from ' + #prog
500bAC                   goto      endvfygen2
500bA
500bAC                   when      $vreturn <> '*OK'
500bAC                   eval      error = *on
500bAC                   eval      $ifcate = '1'
500bAC                   eval      $preturn = $vreturn
500bAC                   eval      $pmessage = $vmessage
500bAC                   goto      endvfygen2
500bA
500bAC                   endsl
500bAC                   endif
610aA
610aA*  Verify on-demand repack slot
610aA
610aAC                   if        $ifodrslotu
610aAC                             and $ifodrslot <> ' '
610aA
610aA*    Department must be sent.
610aA
610aAC                   If        not $itwhdpu
610aAC                   eval      error = *on
610aAC                   eval      $ifodrslote = '1'
610aAC                   eval      $preturn = 'WHDNOTSNT'
610aAC                   exsr      getmsg
610aAC                   goto      endvfygen2
610aAC                   endif
610aA
610aA*    Verify slot
610aA
610aAC                   eval      kydisp = $ifodrslot
610aAC                   exsr      verifyslot
610aA
640aMC                   if        main2err
610aAC                   eval      error = *on
610aAC                   eval      $ifodrslote = '1'
610aAC                   eval      $preturn  = $drireturn
610aAC                   eval      $pmessage = $drimessage
610aAC                   goto      endvfygen2
610aAC                   endif
610aA
610aAC                   endif

     *  Verify designation area (optional).

     C                   if        $itdesgu
     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $vcommand = '*VFY&ADD'
     C                   else
     C                   eval      $vcommand = '*VERIFY'
     C                   endif
     C                   call(e)   'VFYDESG'
     C                   parm                    $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itdesg       $vdesg
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itdesge = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYDESG'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK' and
     C                             $vreturn <> '*CREATE'
     C                   eval      error = *on
     C                   eval      $itdesge = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif

     *  Verify activity zone (optional).

     C                   if        $itactvu
     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $vcommand = '*VFY&ADD'
     C                   else
     C                   eval      $vcommand = '*VERIFY'
     C                   endif
     C                   call(e)   'VFYACTV'
     C                   parm                    $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itactv       $vactv
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itactve = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYACTV'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK' and
     C                             $vreturn <> '*CREATE'
     C                   eval      error = *on
     C                   eval      $itactve = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif

     *  Verify Date Sensitive option.

     C                   if        $itflgdu and
     C                             $itflgd <> 'Y'  and
     C                             $itflgd <> 'N'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $itflgd = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $itflgde = '1'
     C                   eval      $preturn = 'INVLDDFLAG'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   endif

     *  Verify Allow Bulk Pick option.

     C                   if        $itflgbu and
     C                             $itflgb <> 'Y'  and
650iAC                             $itflgb <> 'C'  and
     C                             $itflgb <> 'N'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $itflgb = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $itflgbe = '1'
     C                   eval      $preturn = 'INVLDBFLAG'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   endif

     *  Verify vendor number is not negative.

     C                   if        $itven#u and
     C                             $itven# < 0
     C                   eval      error = *on
     C                   eval      $itven#e = '1'
     C                   eval      $preturn = 'NEGATIVV#'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify replenishment level is not negative.

     C                   if        $itreplu and
     C                             $itrepl < 0
     C                   eval      error = *on
     C                   eval      $itreple = '1'
     C                   eval      $preturn = 'NEGATIVRPL'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify cube is not negative.

     C                   if        $itcubeu and
     C                             $itcube < 0
     C                   eval      error = *on
     C                   eval      $itcubee = '1'
     C                   eval      $preturn = 'NEGATIVCUB'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify catch weight.

     C                   if        $itcwgtu and
     C                             $itcwgt <> 'Y'  and
     C                             $itcwgt <> 'N'
510cA*  Items with itcwgt=S are standard weight items.
510cAC                             and $itcwgt <> 'S'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $itcwgt = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $itcwgte = '1'
     C                   eval      $preturn = 'INVLDCWFLG'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   endif

     *  Verify normal unit of measure.

     C                   if        $itum1u
     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $vcommand = '*VFY&ADD'
     C                   else
     C                   eval      $vcommand = '*VERIFY'
     C                   endif
     C                   call(e)   'VFYUM'
     C                   parm                    $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itum1        $vum
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vsdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itum1e = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYUM'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK' and
     C                             $vreturn <> '*CREATE'
     C                   eval      error = *on
     C                   eval      $itum1e = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif

     *  If one brkdwn 1 unit of measure field sent, all have to be sent.

     C                   if        $itum2u or $itumq2u or $itflg1u
     C                   if        not $itum2u or
     C                             not $itumq2u or
     C                             not $itflg1u
     C                   eval      error = *on
     C                   eval      $itum2e = '1'
     C                   eval      $itumq2e = '1'
     C                   eval      $itflg1e = '1'
     C                   eval      $preturn  = 'UM2NOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif

     *  Verify breakdown 1 unit of measure.

     C                   if        $itum2u
     C                   if        $itum2 <> *blanks or
     C                             $itumq2 <> 0
     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $vcommand = '*VFY&ADD'
     C                   else
     C                   eval      $vcommand = '*VERIFY'
     C                   endif
     C                   call(e)   'VFYUM'
     C                   parm                    $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itum2        $vum
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vsdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itum2e = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYUM'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK' and
     C                             $vreturn <> '*CREATE'
     C                   eval      error = *on
     C                   eval      $itum2e = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif
     C                   endif

     *  Breakdown 1 quantity cannot be negative.

     C                   if        $itum2u
     C                   if        $itumq2 < 0
     C                   eval      error = *on
     C                   eval      $itumq2e = '1'
     C                   eval      $preturn = 'NEGATIVUQ1'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif

     *  Breakdown 1 quantity must be > 0 if um code sent.

     C                   if        $itum2u
     C                   if        $itumq2 = 0 and $itum2 <> ' '
     C                   eval      error = *on
     C                   eval      $itumq2e = '1'
     C                   eval      $preturn = 'ZEROUMQ1'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif

     *  Verify breakdown 1 sell by option.

     C                   if        $itum2u
     C                   if        $itflg1 <> 'Y'  and
     C                             $itflg1 <> 'N'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $itflg1 = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $itflg1e = '1'
     C                   eval      $preturn = 'INVLDBKFL1'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif
     C                   endif

     *  If one brkdwn 2 unit of measure field sent, all have to be sent.

     C                   if        $itum3u or $itumq3u or $itflg2u
     C                   if        not $itum3u or
     C                             not $itumq3u or
     C                             not $itflg2u
     C                   eval      error = *on
     C                   eval      $itum3e = '1'
     C                   eval      $itumq3e = '1'
     C                   eval      $itflg2e = '1'
     C                   eval      $preturn  = 'UM3NOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif

     *  Verify breakdown 2 unit of measure.

     C                   if        $itum3u
     C                   if        $itum3 <> *blanks or
     C                             $itumq3 <> 0
     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $vcommand = '*VFY&ADD'
     C                   else
     C                   eval      $vcommand = '*VERIFY'
     C                   endif
     C                   call(e)   'VFYUM'
     C                   parm                    $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itum3        $vum
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vsdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itum3e = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYUM'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK' and
     C                             $vreturn <> '*CREATE'
     C                   eval      error = *on
     C                   eval      $itum3e = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif
     C                   endif

     *  Breakdown 2 quantity cannot be negative.

     C                   if        $itum3u
     C                   if        $itumq3 < 0
     C                   eval      error = *on
     C                   eval      $preturn = 'NEGATIVUQ2'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif

     *  Breakdown 2 quantity must be > 0 if um code sent.

     C                   if        $itum3u
     C                   if        $itumq3 = 0 and $itum3 <> ' '
     C                   eval      error = *on
     C                   eval      $itumq3e = '1'
     C                   eval      $preturn = 'ZEROUMQ2'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif

     *  Verify breakdown 2 sell by option.

     C                   if        $itum3u
     C                   if        $itflg2 <> 'Y'  and
     C                             $itflg2 <> 'N'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $itflg2 = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $itflg2e = '1'
     C                   eval      $preturn = 'INVLDBKFL2'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   endif
     C                   endif

     *  Dimensions cannot be negative.

     C                   if        $itulenu and
     C                             $itulen < 0
     C                   eval      error = *on
     C                   eval      $itulene = '1'
     C                   eval      $preturn = 'NEGATIVLEN'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   if        $ituwdtu and
     C                             $ituwdt < 0
     C                   eval      error = *on
     C                   eval      $ituwdte = '1'
     C                   eval      $preturn = 'NEGATIVWDT'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   if        $ituhgtu and
     C                             $ituhgt < 0
     C                   eval      $ituhgte = '1'
     C                   eval      error = *on
     C                   eval      $preturn = 'NEGATIVHGT'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
640bA
640bA*  Dimensions cannot compute to greater than 9999.999.
640bA
640bAC                   if        opcdiv > 0
640bAC                   eval(h)   cubetest =
640bAC                             ($itulen * $ituwdt * $ituhgt) / opcdiv
640bAC                   if        cubetest > 9999.999
640bAC                   eval      $itulene = '1'
640bAC                   eval      $ituwdte = '1'
640bAC                   eval      $ituhgte = '1'
640bAC                   eval      error = *on
640bAC                   eval      $preturn = 'LARGECUBE'
640bAC                   exsr      getmsg
640bAC                   goto      endvfygen2
640bAC                   endif
640bAC                   endif

     *  Verify shipping weight is not negative

     C                   if        $itswgtu and
     C                             $itswgt < 0
     C                   eval      error = *on
     C                   eval      $itswgte = '1'
     C                   eval      $preturn = 'NEGATIVWGT'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify build code.(Optional)

     C                   if        $itbldu
     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $vcommand = '*VFY&ADD'
     C                   else
     C                   eval      $vcommand = '*VERIFY'
     C                   endif
     C                   call(e)   'VFYBLD'
     C                   parm                    $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $itbld        $vbld
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $itblde = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYBLD'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK' and
     C                             $vreturn <> '*CREATE'
     C                   eval      error = *on
     C                   eval      $itblde = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl
     C                   endif

     *  Shelf life cannot be negative.

     C                   if        $itslifu and
     C                             $itslif < 0
     C                   eval      error = *on
     C                   eval      $itslife = '1'
     C                   eval      $preturn = 'NEGATIVSLF'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Notice days cannot be negative.

     C                   if        $itndayu and
     C                             $itnday < 0
     C                   eval      error = *on
     C                   eval      $itndaye = '1'
     C                   eval      $preturn = 'NEGATIVNDY'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify Mfg date flag.

     C                   if        $immflgu and
     C                             $immflg <> 'Y'  and
     C                             $immflg <> 'N'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $immflg = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $immflge = '1'
     C                   eval      $preturn = 'INVLDMFLAG'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   endif

     *  Mfg shelf life days cannot be negative

     C                   if        $immdayu and $immday < 0
     C                   eval      error = *on
     C                   eval      $immdaye = '1'
     C                   eval      $preturn = 'NEGATIVMDY'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Distributor cannot be negative.

     C                   if        $imddayu and $imdday < 0
     C                   eval      error = *on
     C                   eval      $imddaye = '1'
     C                   eval      $preturn = 'NEGATIVDDY'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  User days cannot be negative.

     C                   if        $imudayu and $imuday < 0
     C                   eval      error = *on
     C                   eval      $imudaye = '1'
     C                   eval      $preturn = 'NEGATIVUDY'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Mfg tie cannot be negative.

     C                   if        $imtieu and $imtie < 0
     C                   eval      error = *on
     C                   eval      $imtiee = '1'
     C                   eval      $preturn = 'NEGATIVMTI'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Mfg high cannot be negative.

     C                   if        $imhighu and $imhigh < 0
     C                   eval      error = *on
     C                   eval      $imhighe = '1'
     C                   eval      $preturn = 'NEGATIVMHI'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify catch weight warning flag.

     C                   if        $imwrncu and
     C                             $imwrnc <> 'Y'  and
     C                             $imwrnc <> 'N'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $imwrnc = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $imwrnce = '1'
     C                   eval      $preturn = 'INVLDMWRNC'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   endif

     *  If one catchweight variance is sent, both have to be sent.

     C                   if        $imrg1cu or $imrg2cu
     C                   if        not $imrg1cu or
     C                             not $imrg2cu
     C                   eval      error = *on
     C                   eval      $imrg1ce = '1'
     C                   eval      $imrg2ce = '1'
     C                   eval      $preturn  = 'VARNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
     C                   endif

     *  Catch weight From percentage cannot be negative.

     C                   if        $imrg1cu and $imrg1c < 0
     C                   eval      error = *on
     C                   eval      $imrg1ce = '1'
     C                   eval      $preturn = 'NEGATIVRG1'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Catch weight From percentage must be 99 or less than or equal to 75

     C                   if        $imrg1cu and
     C                             $imrg1c <> 99 and $imrg1c > 75
     C                   eval      error = *on
     C                   eval      $imrg1ce = '1'
     C                   eval      $preturn = 'INVLDRG1C'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Catch weight To percentage cannot be negative.

     C                   if        $imrg2cu and $imrg2c < 0
     C                   eval      error = *on
     C                   eval      $imrg2ce = '1'
     C                   eval      $preturn = 'NEGATIVRG2'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Catch weight To percentage must be 99 or less than or equal to 75

     C                   if        $imrg2cu and
     C                             $imrg2c <> 99 and $imrg2c > 75
     C                   eval      error = *on
     C                   eval      $imrg2ce = '1'
     C                   eval      $preturn = 'INVLDRG2C'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Catch weight From percentage must be <= To percentage

     C                   if        $imrg1cu and
     C                             $imrg1c > $imrg2c
     C                   eval      error = *on
     C                   eval      $imrg1ce = '1'
     C                   eval      $preturn = 'INVLDRG12'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify auto assignment of pick slot flag.

     C                   if        $imapcku and
     C                             $imapck <> 'Y'  and
     C                             $imapck <> 'N'

     C                   if        $psubcmd = '*BATADD' or
     C                             $psubcmd = '*BATCHANGE'
     C                   eval      $imapck = 'N'
     C                   else
     C                   eval      error = *on
     C                   eval      $imapcke = '1'
     C                   eval      $preturn = 'INVLDMAPCK'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C                   endif

     *  Number of pick slots cannot be negative.

     C                   if        $imnrpku and $imnrpk < 0
     C                   eval      error = *on
     C                   eval      $imnrpke = '1'
     C                   eval      $preturn = 'NEGATIVNPK'
416aAC                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif
416iA
416iA*    Verify Non-Slotted item flag
416iA
416iAC                   if        $imnsltu and
416iAC                             $imnslt <> 'Y' and $imnslt <> 'N'
416iAC                   if        $psubcmd = '*BATADD' or
416iAC                             $psubcmd = '*BATCHANGE'
416iAC                   eval      $imapck = 'N'
416iAC                   else
416iAC                   eval      error = *on
416iAC                   eval      $imnslte = '1'
416iaC                   eval      $preturn = 'INVLDNSFLG'
416iAC                   exsr      getmsg
416iAC                   goto      endvfygen2
416iAC                   endif
416iAC                   endif
416iA
416iA*    Verify XDock item flag
416iA
416iAC                   if        $imxdcku and
416iAC                             $imxdck <> 'Y' and $imxdck <> 'N'
416iAC                   if        $psubcmd = '*BATADD' or
416iAC                             $psubcmd = '*BATCHANGE'
416iAC                   eval      $imxdck = 'N'
416iAC                   else
416iAC                   eval      error = *on
416iAC                   eval      $imxdcke = '1'
416iaC                   eval      $preturn = 'INVLDXDFLG'
416iAC                   exsr      getmsg
416iAC                   goto      endvfygen2
416iAC                   endif
416iAC                   endif
416iA
416iA*    Verify Lot code item flag
416iA
416iAC                   if        $imlotu and
416iAC                             $imlot <> 'Y' and $imlot <> 'N'
416iAC                   if        $psubcmd = '*BATADD' or
416iAC                             $psubcmd = '*BATCHANGE'
416iAC                   eval      $imlot = 'N'
416iAC                   else
416iAC                   eval      error = *on
416iAC                   eval      $imlote = '1'
416iaC                   eval      $preturn = 'INVLDLFLG'
416iAC                   exsr      getmsg
416iAC                   goto      endvfygen2
416iAC                   endif
416iAC                   endif
416iA
416iA*    Verify Track by License flag
416iA
416iAC                   if        $imltrku and
416iAC                             $imltrk <> 'H' and
416iAC                             $imltrk <> 'L' and
720cMC                             $imltrk <> 'M' and
720cAC                             $imltrk <> 'U'
500 DC**                           $imltrk <> 'N'
417eDC**                           $imltrk <> 'Y' and $imltrk <> 'N'
416iAC                   if        $psubcmd = '*BATADD' or
416iAC                             $psubcmd = '*BATCHANGE'
500 DC**                 eval      $imltrk = 'N'
500 MC                   eval      $imltrk = 'L'
416iAC                   else
416iAC                   eval      error = *on
416iAC                   eval      $imltrke = '1'
416iaC                   eval      $preturn = 'INVLDLTFLG'
416iAC                   exsr      getmsg
416iAC                   goto      endvfygen2
416iAC                   endif
416iAC                   endif
500aA
600aM*    Temporary - Tracking flag can only be set to 'L', 'M' or 'H'
500aA
500aAC                   if        $imltrku and
500aAC                             $imltrk <> 'L'
600aAC                             and $imltrk <> 'M'
600aAC                             and $imltrk <> 'H'
720cAC                             and $imltrk <> 'U'
500aAC                   eval      error = *on
500aAC                   eval      $imltrke = '1'
500aaC                   eval      $preturn = 'INVLDLTFL2'
500aAC                   exsr      getmsg
500aAC                   goto      endvfygen2
500aAC                   endif
ADFbM*    UCI tracking is not allowed for A&D.
ADFbA
ADFaAC                   if        $imltrku and client = AandDFoods
ADFbAC                             and $imltrk = 'U'
ADFbAC                   eval      error = *on
ADFbAC                   eval      $imltrke = '1'
ADFbaC                   eval      $preturn = 'INVLDLTFL3'
ADFbAC                   exsr      getmsg
ADFbAC                   goto      endvfygen2
ADFbAC                   endif
416iA
416iA*  Buyer number cannot be negative.
416iA
416iAC                   if        $imbnbru and $imbnbr < 0
416iAC                   eval      error = *on
416iAC                   eval      $imbnbre = '1'
416iAC                   eval      $preturn = 'NEGATIVB#'
416iAC                   exsr      getmsg
416iAC                   goto      endvfygen2
416iAC                   endif
417 A
417 A*  Days out cannot be negative.
417 A
417 AC                   if        $imodayu and $imoday < 0
417 AC                   eval      error = *on
417 AC                   eval      $imodaye = '1'
417 AC                   eval      $preturn = 'NEGATIVODY'
417 AC                   exsr      getmsg
417 AC                   goto      endvfygen2
417 AC                   endif

640dA*  Brand Flag must be blank,Y or N.
640dA
640dAC                   if        $ifbrdflg <> ' ' and $ifbrdflg <> 'Y' and
640dAc                             $ifbrdflg <> ' ' and $ifbrdflg <> 'N'
640dAC                   eval      error = *on
640dAC                   eval      $ifbrdflge = '1'
640dAC                   eval      $preturn = 'INVLDBRDF'
640dAC                   exsr      getmsg
640dAC                   goto      endvfygen2
640dAC                   endif
640dA
700cA*  Uci Code will be validated using UI900
640dA
640eDC*                  if        $ifucicde <> ' ' and $ifucicde < '1' or
640eDc*                            $ifucicde <> ' ' and $ifucicde > '5'
640eAc                   if        $ifucicdeu
700cA * use ui900 to verify - eliminate hard coding
700cAC                   eval      $lcmd = '*VERIFYB'
700cAc                   eval      $lcmtype = 'UCI1'
700cAc                   eval      $lcmcode =$ifucicde
700cAC                   call      'UI900'
700cAC                   parm                    $lparm
700cAC                   if        $lrtn <> '*OK '
700cDC*                  if        $ifucicde < '1' or
700cDc*                            $ifucicde > '5'
640dAC                   eval      error = *on
640dAC                   eval      $ifucicdee = '1'
640dAC                   eval      $preturn = 'INVLDUCI'
640dAC                   exsr      getmsg
640dAC                   goto      endvfygen2
640dAC                   endif
640eAc                   endif

720cA*  Uci Code must be 2 - unique UCI
720cA
720cAc                   if        $ifucicdeu = '1'
720cMC                   if        $ifucicde <> '2' and
720cMc                             $imltrk = 'U'
720cAC                   eval      error = *on
720cAC                   eval      $ifucicdee = '1'
720cAC                   eval      $preturn = 'INVLDUC1'
720cAC                   exsr      getmsg
720cAC                   goto      endvfygen2
720cAC                   endif
720cAc                   endif

720cA*  Uci Receivning & Selection must be "2" for uci tracking.
720cA
720cAc                   if        $ifucicdeu = '1'
720cMC                   if        $ifrcvmth <> '2' and
720cMc                             $imltrk = 'U'
720cAC                   eval      error = *on
720cAC                   eval      $ifrcvmthe = '1'
720cAC                   eval      $preturn = 'INVLDUC2'
720cAC                   exsr      getmsg
720cAC                   goto      endvfygen2
720cAC                   endif
720cAc                   endif

720cAc                   if        $ifucicdeu = '1'
720cMC                   if        $ifsltmth <> '2' and
720cMc                             $imltrk = 'U'
720cAC                   eval      error = *on
720cAC                   eval      $ifsltmthe = '1'
720cAC                   eval      $preturn = 'INVLDUC2'
720cAC                   exsr      getmsg
720cAC                   goto      endvfygen2
720cAC                   endif
720cAc                   endif

700cA*  Receiving Method will be validated using UI900
640dA
640eAc                   if        $ifrcvmthu
700cA * use ui900 to verify - eliminate hard coding
700cAC                   eval      $lcmd = '*VERIFYB'
700cAc                   eval      $lcmtype = 'UCI2'
700cAc                   eval      $lcmcode =$ifrcvmth
700cAC                   call      'UI900'
700cAC                   parm                    $lparm
700cAC                   if        $lrtn <> '*OK '
640eDC*                  if        $ifrcvmth <> ' ' and $ifrcvmth < '1' or
640eDc*                            $ifrcvmth <> ' ' and $ifrcvmth > '2' or
700cDC*                  if        $ifrcvmth < '1' or
700cDc*                            $ifrcvmth > '2' or
700cDC*                            $ifrcvmth =  ' ' and $ifucicde = '2' or
700cDC*                            $ifrcvmth =  ' ' and $ifucicde = '3' or
700cDC*                            $ifrcvmth =  ' ' and $ifucicde = '4' or
700cDC*                            $ifrcvmth =  ' ' and $ifucicde = '5'
640dAC                   eval      error = *on
640dAC                   eval      $ifrcvmthe = '1'
640dAC                   eval      $preturn = 'INVLDRCV'
640dAC                   exsr      getmsg
640dAC                   goto      endvfygen2
640dAC                   endif
ADFaA*  A&D is not allowed to use UCI receiving because they
ADFaA*  print item license plates at the end of the receiving process
ADFaAC                   if        client = AandDFoods  and
ADFaAc                             $ifrcvmth =  '2'
ADFaAC                   eval      error = *on
ADFaAC                   eval      $ifrcvmthe = '1'
ADFaAC                   eval      $preturn = 'INVLDRC2'
ADFaAC                   exsr      getmsg
ADFaAC                   goto      endvfygen2
ADFaAC                   endif
640eAC                   endif

700cA*  Receiving Method can only be 2 if uci code is NOT 1
640dA
640eAc                   if        $ifrcvmthu
700cDC*                  if        $ifrcvmth = '2'  and $ifucicde <> '2' and
700cDc*                            $ifrcvmth = '2'  and $ifucicde <> '3' and
700cDc*                            $ifrcvmth = '2'  and $ifucicde <> '4' and
700cDc*                            $ifrcvmth = '2'  and $ifucicde <> '5'
700cMC                   if        $ifrcvmth = '2'  and $ifucicde = '1'
640dAC                   eval      error = *on
640dAC                   eval      $ifrcvmthe = '1'
640dAC                   eval      $preturn = 'INVLDRC1'
640dAC                   exsr      getmsg
640dAC                   goto      endvfygen2
640dAC                   endif
640eAC                   endif

720bA*  Receiving Method can only be 5 or 6 if sold by breakdown or
720bA*  has associated ssb item.
720bA
720bAc                   if        $ifrcvmthu
720bMC                   if        $ifrcvmth = '5' and $itflg1 = 'N' or
720bMC                             $ifrcvmth = '6' and $itflg1 = 'N'
720bAC                   eval      error = *on
720bAC                   eval      $ifrcvmthe = '1'
720bAC                   eval      $preturn = 'INVLDRC3'
720bAC                   exsr      getmsg
720bAC                   goto      endvfygen2
720bAC                   endif
720bAC                   endif

700cA*  Selection Method will be validated using UI900
640dA
640eAc                   if        $ifsltmthu
700cA * use ui900 to verify - eliminate hard coding
700cAC                   eval      $lcmd = '*VERIFYB'
700cAc                   eval      $lcmtype = 'UCI3'
700cAc                   eval      $lcmcode =$ifsltmth
700cAC                   call      'UI900'
700cAC                   parm                    $lparm
700cAC                   if        $lrtn <> '*OK '
640eDC*                  if        $ifsltmth <> ' ' and $ifsltmth < '1' or
640eDc*                            $ifsltmth <> ' ' and $ifsltmth > '3' or
700cDC*                  if        $ifsltmth < '1' or
700cDc*                            $ifsltmth > '3' or
700cDC*                            $ifsltmth =  ' ' and $ifucicde = '2' or
700cDC*                            $ifsltmth =  ' ' and $ifucicde = '3' or
700cDC*                            $ifsltmth =  ' ' and $ifucicde = '4' or
700cDC*                            $ifsltmth =  ' ' and $ifucicde = '5'
640dAC                   eval      error = *on
640dAC                   eval      $ifsltmthe = '1'
640dAC                   eval      $preturn = 'INVLDSEL'
640dAC                   exsr      getmsg
640dAC                   goto      endvfygen2
640dAC                   endif
640eAC                   endif

700cA*  Selection Method 2 NOT valid with uci encoding = 1.
640dA
640eAc                   if        $ifsltmthu
640fdC*                  if        $ifsltmth = '2' and $ifucicde < '2' or
700cDC*                  if        $ifsltmth = '2' and $ifucicde < '2'
700cMC                   if        $ifsltmth = '2' and $ifucicde = '1'
640fDc*                            $ifsltmth = '2' and $ifrcvmth <> '2'
640dAC                   eval      error = *on
640dAC                   eval      $ifsltmthe = '1'
640dAC                   eval      $preturn = 'INVLDSE2'
640dAC                   exsr      getmsg
640dAC                   goto      endvfygen2
640dAC                   endif
640eAC                   endif

650dA*  Selection Method 3 not valid on catch weight item.
650dA
650dAc                   if        $ifsltmthu
650dAC                   if        $ifsltmth = '3' and $itcwgt = 'Y'
650dAC                   eval      error = *on
650dAC                   eval      $ifsltmthe = '1'
650dAC                   eval      $preturn = 'INVLDSE3'
650dAC                   exsr      getmsg
650dAC                   goto      endvfygen2
650dAC                   endif
650dAC                   endif

650fA*  Selection Method 3 not valid with Receiving Method 2.
650fA
650fAc                   if        $ifsltmthu
650fAC                   if        $ifsltmth = '3' and $ifrcvmth = '2'
650fAC                   eval      error = *on
650fAC                   eval      $ifsltmthe = '1'
650fAC                   eval      $preturn = 'INVLDSE4'
650fAC                   exsr      getmsg
650fAC                   goto      endvfygen2
650fAC                   endif
650fAC                   endif

740aA*  Selection Method 6 is only valid if the normal UOM for item
740aA*  have a UPC entry.
740aAc                   if        $ifsltmthu
740aAC                   if        $ifsltmth = '6'
740aA /free
740aA   // check normal UOM first
740aA    chain (itwhse: ititem: 'N': $itum1) upc5;
740aA    if not %found(upc5);
740aA /end-free
740aAC                   eval      error = *on
740aAC                   eval      $ifsltmthe = '1'
740aAC                   eval      $preturn = 'INVLDSE5'
740aAC                   exsr      getmsg
740aAC                   goto      endvfygen2
740aaC                   endif
740aaC                   endif
740aaC                   endif
710aA*  Selection Method 4 is only valid if all UOM's for the item
710aA*  have a UPC entry.
710aA
710aAc                   if        $ifsltmthu
710aAC                   if        $ifsltmth = '4'
710aA /free
710aA   // check normal UOM first
710aA    chain (itwhse: ititem: 'N': $itum1) upc5;
710aA    if not %found(upc5);
710aA /end-free
710aAC                   eval      error = *on
710aAC                   eval      $ifsltmthe = '1'
710aAC                   eval      $preturn = 'INVLDSE5'
710aAC                   exsr      getmsg
710aAC                   goto      endvfygen2
710aaC                   endif
710aA /free
720aA   select;
720aA     when $itflg1 = 'Y' and $itum2 <> ' ';
710aA       // check breakdown 1
710aA       chain (itwhse: ititem: '1': $itum2) upc5;
710aA       if not %found(upc5) and $Itflg1 = 'Y';
710aA /end-free
710aAC                   eval      error = *on
710aAC                   eval      $ifsltmthe = '1'
710aAC                   eval      $preturn = 'INVLDSE5'
710aAC                   exsr      getmsg
710aAC                   goto      endvfygen2
710aaC                   endif
710aaC
720aA /free
720aA     when $itflg1 = 'N' and $itum2 <> ' ';
720aA       setll (itwhse: ititem) itemlnk1;
720aA       dow forever = forever;
720aA         reade (itwhse: ititem) itemlnk1;
720aA         if %eof(itemlnk1);
720aA           leave;
720aA         endif;
720aA         // found one is it an ssb Item?
720aA         chain (itwhse: itwhdp: ilitem) piritem1;
720aA         if %found(piritem1);
720aA           if it_ittype = 'S';
720aA             // check for ssb for breakdown 1
720aA             chain (itwhse: it_ititem: '1': $itum2) upc5;
720aA             if not %found(upc5);
720aA /end-free
720aAC                   eval      error = *on
720aAC                   eval      $ifsltmthe = '1'
720aAC                   eval      $preturn = 'INVLDSE5'
720aAC                   exsr      getmsg
720aAC                   goto      endvfygen2
720aaC                   endif
720aaC
720aA /free
720aA           endif;
720aA         endif;
720aA       enddo;
720aA   endsl;

710aA   // check breakdown 2
710aA    chain (itwhse: ititem: '2': $itum3) upc5;
710aA    if not %found(upc5) and $Itflg2 = 'Y';
710aA /end-free
710aAC                   eval      error = *on
710aAC                   eval      $ifsltmthe = '1'
710aAC                   eval      $preturn = 'INVLDSE5'
710aAC                   exsr      getmsg
710aAC                   goto      endvfygen2
710aaC                   endif
710aaC
710aAC                   endif
710aAC                   endif

710aA*  Selection Method 5 is only valid if all breakdown UOM for item
710aA*  have a UPC entry.
710aA
710aAc                   if        $ifsltmthu
710aAC                   if        $ifsltmth = '5'
710aA /free
720aA   select;
740bA     when $itum2 = ' ' and $itum3 = ' ';
740bA /end-free
740bAC                   eval      error = *on
740bAC                   eval      $ifsltmthe = '1'
740bAC                   eval      $preturn = 'INVLDSE6'
740bAC                   exsr      getmsg
740bAC                   goto      endvfygen2
740bA
740bA /free
720aA     when $itflg1 = 'Y' and $itum2 <> ' ';
710aA       // check breakdown 1
710aA       chain (itwhse: ititem: '1': $itum2) upc5;
710aA       if not %found(upc5) and $Itflg1 = 'Y';
710aA /end-free
710aAC                   eval      error = *on
710aAC                   eval      $ifsltmthe = '1'
710aAC                   eval      $preturn = 'INVLDSE5'
710aAC                   exsr      getmsg
710aAC                   goto      endvfygen2
710aaC                   endif
710cA /free
710cA    if not %found(upc5) and $Itflg1 = 'N' and $itum2 <> ' ';
710cA /end-free
710cAC                   eval      error = *on
710cAC                   eval      $ifsltmthe = '1'
710cAC                   eval      $preturn = 'INVLDSE6'
710cAC                   exsr      getmsg
710cAC                   goto      endvfygen2
710caC                   endif
710aaC
710aA /free
720aA     when $itflg1 = 'N' and $itum2 <> ' ';
720aA       setll (itwhse: ititem) itemlnk1;
720aA       dow forever = forever;
720aA         reade (itwhse: ititem) itemlnk1;
720aA         if %eof(itemlnk1);
720aA           leave;
720aA         endif;
720aA         // found one is it an ssb Item?
720aA         chain (itwhse: itwhdp: ilitem) piritem1;
720aA         if %found(piritem1);
720aA           if it_ittype = 'S';
720aA             // check for ssb for breakdown 1
720aA             chain (itwhse: it_ititem: '1': $itum2) upc5;
720aA             if not %found(upc5);
720aA /end-free
720aAC                   eval      error = *on
720aAC                   eval      $ifsltmthe = '1'
720aAC                   eval      $preturn = 'INVLDSE5'
720aAC                   exsr      getmsg
720aAC                   goto      endvfygen2
720aaC                   endif
720aaC
710aA /free
720aA           endif;
720aA         endif;
720aA       enddo;
720aA   endsl;
710aA   // check breakdown 2
710aA    chain (itwhse: ititem: '2': $itum3) upc5;
710aA    if not %found(upc5) and $Itflg2 = 'Y';
710aA /end-free
710aAC                   eval      error = *on
710aAC                   eval      $ifsltmthe = '1'
710aAC                   eval      $preturn = 'INVLDSE5'
710aAC                   exsr      getmsg
710aAC                   goto      endvfygen2
710aaC                   endif
710cA /free
710cA    if not %found(upc5) and $Itflg2 = 'N' and $itum3 <> ' ';
710cA /end-free
710cAC                   eval      error = *on
710cAC                   eval      $ifsltmthe = '1'
710cAC                   eval      $preturn = 'INVLDSE6'
710cAC                   exsr      getmsg
710cAC                   goto      endvfygen2
710caC                   endif
710aaC
710aAC                   endif
710aAC                   endif

740cA /free
740cA   // Repack edits from It116 for gui
740cA   if $ittype = 'R';
740cA     // Repack type must be 1 or 2
740cA     if $kirptp <>'1' and $kirptp<>'2' and $pprogram = 'M17800U';
740cA       error = *on;
740cA       $preturn = 'REPACK01';
740cA       exsr getmsg;
740cA       leavesr;
740cA     endif;

740cA     // on-demand pick slot is only allowed with type 2
740cA     if $kirptp<>'2' and $kidisp<>' ' and $pprogram = 'M17800U';
740cA       error = *on;
740cA       $preturn = 'REPACK02';
740cA       exsr getmsg;
740cA       leavesr;
740cA     endif;

740cA     // on-demand pick slot is required with type 2
740cA     if $kirptp ='2' and $kidisp =' ' and $pprogram = 'M17800U';
740cA       error = *on;
740cA       $preturn = 'REPACK08';
740cA       exsr getmsg;
740cA       leavesr;
740cA     endif;

740cA     // verify slot
740cA     if $kirptp ='2' and $kidisp <>' ' and $pprogram = 'M17800U';
740cA       kydisp = $kidisp;
740cA       exsr verifyslot;
740cA       if main2err;
740cA         error = *on;
740cA         $preturn = 'REPACK15';
740cA         exsr getmsg;
740cA         leavesr;
740cA       endif;

740cA       // slot found - is it acceptable slot
740cA       if $sldesg = 'BFC' or $slaisl='RCV' or $slaisl='RTN' or
740ca          $slaisl='STG' or $slaisl='OSS' or $slaisl='USR'
740cA          or $slstat<>'RP' or $slrsrv='V';
740cA         error = *on;
740cA         $preturn = 'REPACK15';
740cA         exsr getmsg;
740cA         leavesr;
740cA       endif;
740cA     endif;
740cA   endif;
740cA /end-free
     *  Verify tie/high definitions.

     C                   exsr      defvfy
     C     error         cabeq     *on           endvfygen2

     C     endvfygen2    endsr

610aA*----------------------------------------------------------------
610aA*  verifyslot   Verify slot
610aA*----------------------------------------------------------------
610aA
610aAC     verifyslot    begsr

     C                   exsr      clr$slot

     C                   eval      $slwhse = $itwhse
     C                   eval      $slwhdp = $itwhdp
     C                   eval      $sldisp = kydisp

     C                   eval      $dricommand = 'DRISLOT'
610bAC                   eval      $drisubcmd  = '%GET'
610bAC                   eval      $drisys2upd = 'D'
640aDC**                 exsr      zzzdrimain3
640aMC                   exsr      zzzdrimain2

     C     endvfyslot    endsr

610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------
610bA*                  ITEMFLD SQL SUBROUTINES
610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------

610bA*----------------------------------------------------------------
610bA*  AddItemFld  -  Add ITEMFLD record to current version of file
610bA*----------------------------------------------------------------
610bA
610bA /free
610bA  begsr AddItemFld;

         error = *off;

         if $itVer# < 7;
           exsr AddItemFld520;
           leavesr;
         endif;

         exec sql insert into itemfld values(:ifrec);

         // If a column is not found, try using previous record version.

         if sqlstt = sqlUndefColumn;
           exsr AddItemFld520;
           leavesr;
         endif;

         if sqlstt <> sqlSuccess;
           error = *on;
           leavesr;
         endif;

       endsr;
      /end-free

610bA*----------------------------------------------------------------
610bA*  AddItemFld520  -  Add ITEMFLD record to 5.20 version of file
610bA*----------------------------------------------------------------
610bA
610bA /free
610bA  begsr AddItemFld520;

         error = *off;

         exec sql insert into itemfld
640dD             //(ifwhse, ifitem, ifcat, ifcaseovf)
640dD             //values (:ifwhse, :ifitem, :ifcat, :ifcaseovf);
640dM             (ifwhse, ifitem, ifcat, ifcaseovf,
640dA              ifucicde, ifrcvmth, ifsltmth, ifbrdflg)
640dM             values (:ifwhse, :ifitem, :ifcat, :ifcaseovf,
640dA              :ifucicde, :ifrcvmth, :ifsltmth, :ifbrdflg);
         if sqlstt <> sqlSuccess;
           error = *on;
           leavesr;
         endif;

       endsr;
      /end-free

610bA*----------------------------------------------------------------
610bA*  DltItemFld  -  Delete ITEMFLD record
610bA*----------------------------------------------------------------
610bA
610bA /free
610bA  begsr DltItemFld;

         error = *off;

         exec sql delete from itemfld
                  where ifwhse = :kyWhse and ifitem = :kyItem;

         if sqlstt <> sqlSuccess;
           error = *on;
           leavesr;
         endif;

       endsr;
      /end-free

610bA*----------------------------------------------------------------
610bA*  GetItemFld  -  Get current record format of ITEMFLD file
610bA*----------------------------------------------------------------
610bA
610bA /free
610bA  begsr GetItemFld;

         foundItemFld = *on;

         if $itVer# < 7;
           exsr GetItemFld520;
           leavesr;
         endif;

         exec sql select * into :ifrec
                  from itemfld
                  where ifwhse = :kyWhse and ifitem = :kyItem;

         // If a column is not found, try getting previous record version.

         if sqlstt = sqlUndefColumn;
           exsr GetItemFld520;
           leavesr;
         endif;

650aD    // If a different error, then get out.
650aA    // If a different error
650aA    if sqlstt <> sqlSuccess;
650aA      foundItemFld = *off;
650aA      // if ITEMFLD record not found look for KITITEM for ODRS
650aA      chain(n) (kywhse:kyitem) kititem;
650aA      if not %found(kititem);
650aD        // error = *on;
650aA        leavesr;
650aA      else;
650aA        $ifodrslot = kidisp;
650aA        ifodrslot = kidisp;
650aA        leavesr;
650aA      endif;
650aA    else;
650aA      // Even if ITEMFLD record found we should now retrieve
650aA      //  ODRS from KITITEM
650aA      if $ittype = 'R';
650aA        chain(n) (kywhse:kyitem) kititem;
650aA        if not %found(kititem);
650aA           leavesr;
650aA        else;
650aA           $ifodrslot = kidisp;
650aA           ifodrslot = kidisp;
650aA           leavesr;
650aA        endif;
650aA      endif;
         endif;

       endsr;
      /end-free

610bA*----------------------------------------------------------------
610bA*  GetItemFld520  -  Get 5.20 record format of ITEMFLD file
610bA*----------------------------------------------------------------
610bA
610bA /free
610bA  begsr GetItemFld520;

         foundItemFld = *on;

640dD    //exec sql select ifwhse, ifitem, ifcat, ifcaseovf
640dM    exec sql select ifwhse, ifitem, ifcat, ifcaseovf,
640dA                    ifucicde, ifrcvmth, ifsltmth, ifbrdflg
640dD             //into :ifwhse, :ifitem, :ifcat, :ifcaseovf
640dM             into :ifwhse, :ifitem, :ifcat, :ifcaseovf,
640dA                   :ifucicde, :ifrcvmth, :ifsltmth, :ifbrdflg
                  from itemfld
                  where ifwhse = :kyWhse and ifitem = :kyItem;

         if sqlstt <> sqlSuccess;
           foundItemFld = *off;
           leavesr;
         endif;

       endsr;
      /end-free

610bA*----------------------------------------------------------------
610bA*  UpdItemFld  -  Add ITEMFLD record to current version of file
610bA*----------------------------------------------------------------
610bA
610bA /free
610bA  begsr UpdItemFld;

         error = *off;

         if $itVer# < 7;
           exsr UpdItemFld520;
           leavesr;
         endif;

         exec sql update itemfld
                  set ifcat = :ifcat,
                      ifcaseovf = :ifcaseovf,
640dD                 //ifodrslot = :ifodrslot
640dM                 ifodrslot = :ifodrslot,
640dA                 ifucicde  = :ifucicde,
640dA                 ifrcvmth  = :ifrcvmth,
640dA                 ifsltmth  = :ifsltmth,
640dA                 ifbrdflg  = :ifbrdflg
                  where ifwhse = :kyWhse and ifitem = :kyItem;

         // If a column is not found, try using previous record version.

         if sqlstt = sqlUndefColumn;
           exsr UpdItemFld520;
           leavesr;
         endif;

         if sqlstt <> sqlSuccess;
650aA       chain(n) (kywhse:kyitem) kititem;
650aA       if not %found(kititem);
               leavesr;
            else;
               $ifodrslot = kidisp;
               leavesr;
            endif;
         else;
650aA       chain(n) (kywhse:kyitem) kititem;
650aA       if not %found(kititem);
               leavesr;
            else;
               $ifodrslot = kidisp;
               leavesr;
            endif;
         endif;

       endsr;
      /end-free

610bA*----------------------------------------------------------------
610bA*  UpdItemFld520  -  Add ITEMFLD record to 5.20 version of file
610bA*----------------------------------------------------------------
610bA
610bA /free
610bA  begsr UpdItemFld520;

         error = *off;

         exec sql update itemfld
                  set ifcat = :ifcat,
640dD                 //ifcaseovf = :ifcaseovf
640dM                 ifcaseovf = :ifcaseovf,
640dA                 ifucicde = :ifucicde,
640dA                 ifrcvmth = :ifrcvmth,
640dA                 ifsltmth = :ifsltmth,
640dA                 ifbrdflg = :ifbrdflg
                  where ifwhse = :kyWhse and ifitem = :kyItem;

         if sqlstt <> sqlSuccess;
           error = *on;
           leavesr;
         endif;

       endsr;
      /end-free

640fA*----------------------------------------------------------------
640fA*  UpdSSBDepItm   -  Updates dependant item for SSB items
640fA*----------------------------------------------------------------
640fA
640fAc     updssbdepitm  begsr
640fA * save the key fields in order to reposition back to where I am
640fAc                   eval      svssbilwhse = ilwhse
640fAc                   eval      svssbilitm2 = ilitm2
640fAc                   eval      svssbilitem = ilitem
640fA*  Update any linked (dependent) items.
640fA
640fA*    Loop through linked items.
640fA
640fAC     keyitssb      setll     itemlnk1
640fAC                   dow       forever = forever

640fAC     keyitssb      reade     itemlnk1
640fAC                   if        %eof
640fAC                   leave
640fAC                   endif

640fA*    Update linked item record.

640fA*      Get & lock record

640fAC     keyitl        chain     piritem
640fAC                   if        not %found
640fAC                   iter
640fAC                   endif

640fA*      If Normal or Broken case item, get next linked item.
640fA*      or Repack item

640fAC                   if        ittype = ' ' or ittype = 'B'
640fAC                             or ittype = 'R'
640fAC                   iter
640fAC                   endif

640fA*      Move information into item fields.

640fAC                   if        $itstypu
640fAC                   eval      itstyp = $itstyp
640fAC                   endif

640fAC                   if        $itwhdpu
640fAC                   eval      itwhdp = $itwhdp
640fAC                   endif

640fAC                   if        $itdesgu
640fAC                   eval      itdesg = $itdesg
640fAC                   endif

640fAC                   if        $itactvu
640fAC                   eval      itactv = $itactv
640fAC                   endif

640fAC                   if        $itflgdu
640fAC                   eval      itflgd = $itflgd
640fAC                   endif

640fAC                   if        $itflgbu
640fAC                   eval      itflgb = $itflgb
640fAC                   endif

640fAC                   if        $itven#u
640fAC                   eval      itven# = $itven#
640fAC                   endif

640fAC                   if        $itvit#u
640fAC                   eval      itvit# = $itvit#
640fAC                   endif

640fAC                   if        $itreplu
640fAC                   eval      itrepl = $itrepl
640fAC                   endif

640fAC                   if        $itum1u
640fAC                   eval      itum1 = $itum1
640fAC                   endif

640fAC                   if        $itum2u
640fAC                   eval      itum2 = $itum2
640fAC                   endif

640fAC                   if        $itumq2u
640fAC                   eval      itumq2 = $itumq2
640fAC                   endif

640fAC                   if        $itflg1u
640fAC                   eval      itflg1 = $itflg1
640fAC                   endif

640fAC                   if        $itum3u
640fAC                   eval      itum3 = $itum3
640fAC                   endif

640fAC                   if        $itumq3u
640fAC                   eval      itumq3 = $itumq3
640fAC                   endif

640fAC                   if        $itflg2u
640fAC                   eval      itflg2 = $itflg2
640fAC                   endif

640fAC                   if        $itulenu
640fAC                   eval      itulen = $itulen
640fAC                   endif

640fAC                   if        $ituwdtu
640fAC                   eval      ituwdt = $ituwdt
640fAC                   endif

640fAC                   if        $ituhgtu
640fAC                   eval      ituhgt = $ituhgt
640fAC                   endif

640fAC                   if        $itcubeu
640fAC                   eval      itcube = $itcube
640fAC                   exsr      calccube
640fAC                   endif

640fAC                   if        $itswgtu
640fAC                   eval      itswgt = $itswgt
640fAC                   endif

640fAC                   if        $itcwgtu
640fAC                   eval      itcwgt = $itcwgt
640fAC                   endif

640fAC                   if        $itbldu
640fAC                   eval      itbld = $itbld
640fAC                   endif

640fAC                   if        $itslifu
640fAC                   eval      itslif = $itslif
640fAC                   endif

640fAC                   if        $itndayu
640fAC                   eval      itnday = $itnday
640fAC                   endif

640fA*      Update item record.

640fAC                   update(e) itrec
640fAC                   if        %error
640fAC                   endif

640fA*    Update linked itemmsc record.

640fA*      Get & lock record


640fAC     keyitl        chain     itemmsc
640fAC                   if        not %found
640fAC                   iter
640fAC                   endif

640fA*      Move information into ITEMMSC fields.

640fAC                   if        $imtieu
640fAC                   eval      imtie = $imtie
640fAC                   endif

640fAC                   if        $imhighu
640fAC                   eval      imhigh = $imhigh
640fAC                   endif

640fAC                   if        $immflgu
640fAC                   eval      immflg = $immflg
640fAC                   endif

640fAC                   if        $imddayu
640fAC                   eval      imdday = $imdday
640fAC                   endif

640fAC                   if        $imudayu
640fAC                   eval      imuday = $imuday
640fAC                   endif

640fAC                   if        $immdayu
640fAC                   eval      immday = $immday
640fAC                   endif

640fAC                   if        $imwrncu
640fAC                   eval      imwrnc = $imwrnc
640fAC                   endif

640fAC                   if        $imrg1cu
640fAC                   eval      imrg1c = $imrg1c
640fAC                   endif

640fAC                   if        $imrg2cu
640fAC                   eval      imrg2c = $imrg2c
640fAC                   endif

640fAC                   if        $imapcku
640fAC                   eval      imapck = $imapck
640fAC                   endif

640fAC                   if        $imnrpku
640fAC                   eval      imnrpk = $imnrpk
640fAC                   endif

640fAC                   if        $imnsltu
640fAC                   eval      imnslt = $imnslt
640fAC                   endif

640fAC                   if        $imxdcku
640fAC                   eval      imxdck = $imxdck
640fAC                   endif

640fAC                   if        $imbnbru
640fAC                   eval      imbnbr = $imbnbr
640fAC                   endif

640fAC                   if        $imbnamu
640fAC                   eval      imbnam = $imbnam
640fAC                   endif

640fAC                   if        $imvnamu
640fAC                   eval      imvnam = $imvnam
640fAC                   endif

640fAC                   if        $imbrndu
640fAC                   eval      imbrnd = $imbrnd
640fAC                   endif

640fAC                   if        $imlotu
640fAC                   eval      imlot = $imlot
640fAC                   endif

640fAC                   if        $imltrku
640fAC                   eval      imltrk = $imltrk
640fAC                   endif

640fAC                   if        $imodayu
640fAC                   eval      imoday = $imoday
640fAC                   endif

640fA*      Update itemmsc record.

640fAC                   update(e) imrec
640fAC                   if        %error
640fAC                   endif
640fA
640fA*    Update linked itemmsc record.
640fA
640fA*      Get & lock record
640fA
640fAC**   keyitl        chain     itemfld
640fAC**                 if        not %found
640fAC                   eval      kyWhse = ilwhse
640fAC                   eval      kyItem = ilitem
640fAC                   exsr      GetItemFld
640fAC                   if        not foundItemFld
640fAC                   iter
640fAC                   endif
640fA
640fA*      Move information into ITEMFLD fields.
640fA
640fAC                   if        $ifcatu
640fAC                   eval      ifcat = $ifcat
640fAC                   endif
640fA
640fAC                   if        $ifodrslotu
640fAC                   eval      ifodrslot = $ifodrslot
640fAC                   endif
640fAC                   if        $ifcaseovfu
640fAC                   eval      ifcaseovf = $ifcaseovf
640fAC                   endif
640fAC                   if        $ifucicdeu
640fAC                   eval      ifucicde = $ifucicde
640fAC                   endif
640fAC                   if        $ifrcvmthu
640fAC                   eval      ifrcvmth = $ifrcvmth
640fAC                   endif
640fAC                   if        $ifsltmthu
640fAC                   eval      ifsltmth = $ifsltmth
640fAC                   endif
640fAC                   if        $ifbrdflgu
640fAC                   eval      ifbrdflg = $ifbrdflg
640fAC                   endif
640fA
640fA*      Update itemfld record.
640fA
640fAC**                 update(e) ifrec
640fAC**                 if        %error
640fAC                   exsr      UpdItemFld
640fAC                   if        error
640fAC                   eval      error = *off
640fAC                   endif
640fA
640fA*    Replace linked item tie/high definitions.
640fA
640fAC                   if        $idsdefu(1) or
640fAC                             $idsdefu(2) or
640fAC                             $idsdefu(3) or
640fAC                             $idsdefu(4) or
640fAC                             $idsdefu(5)
640fAC                   exsr      defrpllnk
640fAC                   endif
640fAC                   enddo
640fAc     keyitssbsave  setgt     itemlnk1

640fAc                   endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*                     DRI SUBROUTINES
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
640aM*  zzzdrimain2  Call DRIMAIN2
     *----------------------------------------------------------------

640aDC**   zzzdrimain3   begsr
640aMC     zzzdrimain2   begsr
640aMC                   eval      main2err = *off
640aMC                   eval      main2callerr = *off
640aMC                   eval      main2rtnerr = *off

     C                   select
     C                   when      $dricommand = 'DRISLOT'
     C                   eval      drislot = *on
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = 'DRISLOT'
640aDC**                 call(e)   'DRIMAIN3'
640aMC                   call(e)   'DRIMAIN2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
640aDC**                 call(e)   'DRIMAIN3'
640aMC                   call(e)   'DRIMAIN2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
640aMC                   eval      main2err = *on
640aMC                   eval      main2callerr = *on
     C                   eval      $drireturn  = 'CALLERROR'
     C                   eval      $drimessage = 'Error occured on call to '
640aMC                                         + 'DRIMAIN2'
     C                                         + '/' + %trim($drisubcmd)
     C                                         + ' from ' + $pprogram

     C                   when      $drireturn <> '*OK'
640aMC                   eval      main2err = *on
640aMC                   eval      main2rtnerr = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = 'DRISLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr
