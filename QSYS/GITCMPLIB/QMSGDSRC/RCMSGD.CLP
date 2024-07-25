/*------------------------------------------------------------------*/
/*  English Version (Spanish version is RCMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  RCMSGD      Create PIRMSGF Message Descriptions RCpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  Note:                                                           */
/*   The following types of messages should begin with msgid 70:    */
/*     - Locked records.                                            */
/*     - Non-existing records.                                      */
/*     - Error writting/updating records.                           */
/*                                                                  */
/*   07/15/98  RH  4.09  add messages RC20003 & RC20004             */
/*   08/23/99  MLB 4.12  Add message RC16021                        */
/*   07/15/00  RRH 4.14a Add message RC20005                        */
/*   07/18/00  RRH 4.14b Add message RC20006                        */
/*   06/29/01  RRH 4.15i Add message RC20007                        */
/*   02/02/02  MLB 4.16  Revised message text for RC20005.          */
/*   02/20/02  MLB 4.15  Add message RC20008                        */
/*   03/01/02  DAS 4.16b Add message RC16022                        */
/*   10/01/03  RH  4.17a Add message RC20009                        */
/*   10/27/03  MLB 4.17b Add message RC20010, RC20011.              */
/*   11/11/03  MLB 4.17c Add message RC20012, RC20013.              */
/*   12/16/03  MLB 4.17d Add message RC20014, RC20015, RC20016.     */
/*   11/23/04  RH  5.00a Add message RC20017                        */
/*   12/18/03  RH  5.00b Add message RC20018                        */
/*   12/29/04  RH  5.00c Add message RC16023                        */
/*   02/15/05  RH  5.00d Add message RC20019                        */
/*   03/30/05  MLB 5.00e Add message RC20020                        */
/*   03/06/06  RH  5.00f Shorten RC20002 to better fit rf screen    */
/*   11/25/08  DAS 5.20a Added missing message RC20021.             */
/*                       Added message RC20022 - RC20029.           */
/*   10/09/12  DAS 6.40a Added message RC16024                      */
/*   09/22/15  MLB 7.00  Added message RC20030.                     */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE('*LIBL')
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  RC11501 Invalid option */

             CHGVAR     VAR(&MSGID) VALUE('RC11501')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid option sent to RC115 (&1).') +
                          SECLVL('Cause . . . . . :   Option &1 is +
                          not valid for program RC115. &N Recovery  +
                          . . . :   Contact your DP manager for +
                          instructions.') SEV(30) FMT((*CHAR 8))
             ENDDO

/*  RC11502 Batch in use  */

             CHGVAR     VAR(&MSGID) VALUE('RC11502')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch &1 is being used by another +
                          user.') SECLVL('Cause . . . . . :   +
                          Someone else is already working with +
                          batch &1. &N Recovery  . . . :   Wait +
                          until the other user is finished and try +
                          again.') SEV(30) FMT((*DEC 7))
             ENDDO

/*  RC11503 Status code indicates that batch is in use  */

             CHGVAR     VAR(&MSGID) VALUE('RC11503')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          status of batch &1 indicates that it is +
                          already being used.') SECLVL('''Cause . . +
                          . . . :   Someone else is already working +
                          with batch &1. The batch status should +
                          indicate what is being done with the +
                          batch. Status codes: S=Suspend, +
                          E=Editing, D=Deleting, L=Listing, +
                          P=Posting, V=Verified and C=Completed. +
                          The batch status must be ''S'' or ''V'' +
                          for you to work with it. A batch can only +
                          be posted after an edit listing has +
                          printed without any errors which sets the +
                          status to ''V''. &N Recovery  . . . :   +
                          Wait until the other user is finished and +
                          try again.''') SEV(30) FMT((*DEC 7))
             ENDDO

/*  RC11504 Posting not allowed */

             CHGVAR     VAR(&MSGID) VALUE('RC11504')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch must be verified before +
                          posting.') SECLVL('Cause . . . . . :   +
                          Batch &1 can not be posted until it is +
                          verified. &N Recovery  . . . :   Take +
                          option 9 to print the verification +
                          listing.  When this listing prints +
                          without any errors the batch will be +
                          marked a verified.') SEV(30) FMT((*DEC 7))
             ENDDO

/*  RC13071 Record not added to receiving batch detail file  */

             CHGVAR     VAR(&MSGID) VALUE('RC13071')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          record was not added to the receiving +
                          batch detail file.') SECLVL('Cause . . . +
                          . . :   An error occured while trying to +
                          add this record to the receiving batch +
                          entry file. &N Recovery  . . . :   +
                          Contact your DP manager for +
                          instructions.') SEV(40)
             ENDDO

/*  RC13072 Record not updated in receiving batch detail file  */

             CHGVAR     VAR(&MSGID) VALUE('RC13072')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          record was not updated in the receiving +
                          batch detail file.') SECLVL('Cause . . . +
                          . . :   An error occured while trying to +
                          update the record to the receiving batch +
                          detail file. &N Recovery  . . . :   +
                          Contact your DP manager for recovery +
                          instructions.') SEV(40)
             ENDDO

/*  RC13073 Purchase order does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('RC13073')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Purchase order &1 does not exist.') +
                          SECLVL('Cause . . . . . :   Purchase +
                          order &1 does not exist in the purchase +
                          order file. &N Recovery  . . . :   Enter +
                          a purchase order number that has already +
                          been defined.') SEV(40) FMT((*DEC 9 0))
             ENDDO

/*  RC13074 Item does not exist in purchase order.  */

             CHGVAR     VAR(&MSGID) VALUE('RC13074')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &2 does not exist in purchase order &1.') +
                          SECLVL('Cause . . . . . :   Purchase +
                          order &1 does not contain item &2. &N +
                          Recovery  . . . :   Enter an item number +
                          that is a part of purchase order &1 or +
                          enter a new purchase order number.') +
                          SEV(40) FMT((*DEC 9 0) (*CHAR 15))
             ENDDO

/*  RC13075 BATRC record is locked.  */

             CHGVAR     VAR(&MSGID) VALUE('RC13075')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Detail item is currently locked by +
                          another user.') SECLVL('Cause . . . . . +
                          :   The detail item you have chosen is +
                          being used by another user and can not be +
                          shared. &N Recovery  . . . :   Choose +
                          another detail item or wait until the +
                          other user is finished with the log and +
                          try again.') SEV(40)
             ENDDO

/*  RC13076 Detail item not found in receiving batch file.  */

             CHGVAR     VAR(&MSGID) VALUE('RC13076')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Detail item not found.') +
                          SECLVL('Cause . . . . . :   The detail +
                          item you have chosen does not exist in +
                          the receiving batch file. &N Recovery  . +
                          . . :   Press F5 to refresh the screen +
                          and choose another detail item.') SEV(40)
             ENDDO

/*  RC15520 Item put away successfully. */

             CHGVAR     VAR(&MSGID) VALUE('RC15520')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          pieces put-away on &2 pallets for item +
                          &3.') SECLVL('No further information') +
                          SEV(00) FMT((*DEC 5 0) (*DEC 3 0) (*CHAR 15))
             ENDDO

/*  RC15521 Item does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('RC15521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 does not exist.') SECLVL('Cause . . . +
                          . . :   Item &1 does not exist in the +
                          item master file. &N Recovery  . . . :   +
                          Enter an item number that exists and try +
                          again.') SEV(40) FMT((*CHAR 15))
             ENDDO

/*  RC15522 Tie/High definitions do not exist for item. */

             CHGVAR     VAR(&MSGID) VALUE('RC15522')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Tie/High definition does not exist +
                          for item &1.') SECLVL('Cause . . . . . +
                          :   Item &1 does not have any tie/high +
                          definitions defined. &N Recovery  . . . +
                          :   Use item maintenance to define at +
                          least one tie/high definition for item +
                          &1.') SEV(40) FMT((*CHAR 15))
             ENDDO

/*  RC15523 Receiving options do not exist. */

             CHGVAR     VAR(&MSGID) VALUE('RC15523')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Receiving options do not exist.') +
                          SECLVL('Cause . . . . . :   Receiving +
                          options were not found. &N Recovery  . . +
                          . :   Go to the administration menu and +
                          enter the receiving options.') SEV(40)
             ENDDO

/*  RC15524 No slots available for put away. */

             CHGVAR     VAR(&MSGID) VALUE('RC15524')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          slots available for put away.') +
                          SECLVL('Cause . . . . . :   There were no +
                          verified slots found that match the +
                          tie/high definition(s) for the item. &N +
                          Recovery  . . . :   Only verified slots +
                          that have a corresponding tie/high +
                          definition defined for the item will be +
                          looked for. You must either verify some +
                          of those slots or you can define other +
                          tie/high definitions for the item in +
                          which there are verified slots +
                          available.') SEV(40)
             ENDDO

/*  RC15525 Not enough slots available for put away. */

             CHGVAR     VAR(&MSGID) VALUE('RC15525')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Not +
                          enough slots available for put away.') +
                          SECLVL('Cause . . . . . :   There were +
                          not enough verified slots found that +
                          match the tie/high definition(s) for the +
                          item. &N Recovery  . . . :   Only +
                          verified slots that have a corresponding +
                          tie/high definition defined for the item +
                          will be looked for. You must either +
                          verify some of those slots or you can +
                          define other tie/high definitions for the +
                          item in which there are verified slots +
                          available.') SEV(40)
             ENDDO

/*  RC15526 No slots available for put away in same aisle. */

             CHGVAR     VAR(&MSGID) VALUE('RC15526')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          slots available for put away +
                          in same aisle.') +
                          SECLVL('Cause . . . . . :   There were no +
                          verified slots found that match the +
                          existing aisle for the item. &N +
                          Recovery  . . . :   Only verified slots +
                          that have a corresponding aisle tie/high +
                          definition defined for the item will be +
                          looked for. You must either verify some +
                          of those slots or you can define other +
                          tie/high definitions for the item in +
                          which there are verified slots +
                          available.') SEV(40)
             ENDDO

/*  RC15527 Not enough slots available for put away in same aisle. */

             CHGVAR     VAR(&MSGID) VALUE('RC15527')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Not +
                          enough slots available for put away +
                          in same aisle.') +
                          SECLVL('Cause . . . . . :   There were +
                          not enough verified slots found that +
                          match the tie/high definition(s) and aisle +
                          for the item. &N Recovery  . . . :   Only +
                          verified slots that have a corresponding +
                          aisle tie/high definition defined for the +
                          item will be looked for. You must either +
                          verify some of those slots or you can +
                          define other tie/high definitions for the +
                          item in which there are verified slots +
                          available.') SEV(40)
             ENDDO

/*  RC16020 Item put away successfully. */

             CHGVAR     VAR(&MSGID) VALUE('RC16020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          pieces put-away on &2 pallets for item +
                          &3.') SECLVL('No further information') +
                          SEV(00) FMT((*CHAR 10) (*DEC 3 0) (*CHAR 15))
             ENDDO

/*  RC16021 xxx of yyy Pick slots assigned.  */

             CHGVAR     VAR(&MSGID) VALUE('RC16021')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          pick slots assigned automatically to item +
                          &3 for a total of &2 pick slots.') +
                          SECLVL('Cause . . . . . :   The system +
                          value is set to ''Y'' Allow automatic +
                          assignment of pick slots. The number of +
                          pick slots set for this item is &2. &N +
                          Recovery  . . . :   If the number of +
                          slots assigned is less than &2: Perform +
                          one of the following: 1.) Check for +
                          unverified slots and verify them.  +
                          Perform slot maintenance and assign the +
                          item to the correct slots.  2.) Proceed +
                          with receiving, no action is necessary.') +
                          SEV(00) FMT((*DEC 5) (*DEC 5) (*CHAR 15))
             ENDDO


/*  RC16022 No pick slot found for crossdock */

             CHGVAR     VAR(&MSGID) VALUE('RC16022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          pick slot found to receive crossdock +
                          quantity.') SECLVL('Cause . . . . . :   +
                          The item being received has a quantity to +
                          be crossdocked. The crossdock quantity +
                          can only be put into a pick slot. +
                          However, a pick slot was not found for +
                          the item. &N Recovery  . . . :   Create a +
                          pick slot for the item and try again.') +
                          SEV(40)
             ENDDO

/*  RC16023 No pick slot for Special Receive */

             CHGVAR     VAR(&MSGID) VALUE('RC16023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          pick slot found to do special +
                          receive.') SECLVL('Cause . . . . . :   +
                          The item being received using special +
                          receive does not have a pick slot.+
                          Special receive forces the product +
                          into a pick slot. +
                          Recovery  . . . :   Create a +
                          pick slot for the item and try again.') +
                          SEV(40)
             ENDDO

/*  RC16024 No Tie/High definition large enough for qty.   640aA*/

             CHGVAR     VAR(&MSGID) VALUE('RC16024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          Tie/High definition large enough for +
                          quantity &1') SECLVL('Cause . . . . . :   +
                          Single pallet is being received that is +
                          not allowed to be split and none of the +
                          tie/high definitions are large enough to +
                          hold the quantity being received, &1. &N +
                          Recovery  . . . :   Use item maintenance +
                          to define at least one tie/high +
                          definition that is equal to or greater +
                          than &1') SEV(40) FMT((*DEC 5 0))
             ENDDO

/*  RC20001 Scanned slot is invalid.(To slot)  */

             CHGVAR     VAR(&MSGID) VALUE('RC20001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot.') SECLVL('Cause . . . +
                          . . :   The slot number you have +
                          entered/scanned is different from the +
                          put-away slot &1.  &N Recovery  . . . :   +
                          Put the item in &1 slot and enter/scan &1 +
                          slot.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  RC20002 Transaction is closed.         */

             CHGVAR     VAR(&MSGID) VALUE('RC20002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Trans is closed or started by +
                          another user.') SECLVL('Cause . . . . . +
                          :   The trans &1 is either closed +
                          or started by another user.  &N Recovery  +
                          . . . :   Enter/Scan other license and +
                          try your request again.') SEV(30) +
                          FMT((*DEC 7 0))
             ENDDO

/*  RC20003 Quantity must be > 0.          */

             CHGVAR     VAR(&MSGID) VALUE('RC20003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid quantity.') +
                          SECLVL('Cause . . . . . +
                          :   Quantity must be greater than 0. +
                          &N Recovery . . . :   Enter new quantity.') +
                          SEV(30)
             ENDDO

/*  RC20004 Quantity can't be > than qty to be put away  */

             CHGVAR     VAR(&MSGID) VALUE('RC20004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid quantity.') +
                          SECLVL('Cause . . . . . +
                          :   Quantity can not be greater +
                          than quantity to be put away +
                          &N Recovery . . . :   Enter new quantity.') +
                          SEV(30)
             ENDDO

/*  RC20005 Invalid slot, put in overflow      */

             CHGVAR     VAR(&MSGID) VALUE('RC20005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

 /*  This line is the message before the 4.16 change.                (416)  */
 /*                       MSG('Invalid slot, put in overflow.') +    (416)  */
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Older product in stock. Put in overflow.') +
                          SECLVL('Cause . . . +
                          . . :   Overflow slots exist for +
                          the pick slot scanned, can not put in +
                          pick slot.  &N Recovery  . . . :   +
                          Put the item in an overflow slot.') +
                          SEV(30)
             ENDDO

/*  RC20006 Slot must match item designation code.   */

             CHGVAR     VAR(&MSGID) VALUE('RC20006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot must match item designation.') +
                          SECLVL('Cause . . . +
                          . . :   Slot designation does not +
                          match the item HARD designation code. +
                          &N Recovery  . . . :   +
                          Put the item in a slot that matches +
                          the item designation code.') +
                          SEV(30)
             ENDDO

/*  RC20007 Invalid slot, slot inactive        */

             CHGVAR     VAR(&MSGID) VALUE('RC20007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot, slot inactive.') +
                          SECLVL('Cause . . . +
                          . . :   The scanned slot is inactive. +
                          Cannot put product into an inactive +
                          slot.  &N Recovery  . . . :   +
                          Put the item in another slot.') +
                          SEV(30)
             ENDDO

/*  RC20008 Label / License already scanned in. */

             CHGVAR     VAR(&MSGID) VALUE('RC20008')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          already scanned in by &3.') SECLVL('Cause +
                          . . . . . :   &1 number &2 has already +
                          been scanned in by user &3. &N +
                          Recovery  . . . :   Verify the number +
                          scanned in is correct or scan a new +
                          number and try your request again.') +
                          SEV(30) FMT((*CHAR 10) (*DEC 7 0) (*CHAR 10))
             ENDDO

/*  RC20009 Must stage total remaining quantity */

             CHGVAR     VAR(&MSGID) VALUE('RC20009')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Stage total remaining &1.') SECLVL('Cause +
                          . . . :   Must stage the total +
                          remaining quantity of &1. +
                          &N Recovery  . . . :   +
                          Change the quantity to the total remaining +
                          &1.') SEV(30) FMT((*DEC 7 0))
             ENDDO

/*  RC20010 Pallet position must be greater than zero. */

             CHGVAR     VAR(&MSGID) VALUE('RC20010')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Pallet position must be > 0.') +
                          SECLVL('Cause . . . :   User entered +
                          a pallet position that is less than or +
                          equal to zero. &N Recovery  . . . :   +
                          Change the value entered for the pallet +
                          position to a value greater than zero.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  RC20011 Pallet position greater than slot maximum. */

             CHGVAR     VAR(&MSGID) VALUE('RC20011')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Pallet position must be <= &2.') +
                          SECLVL('Cause . . . :   User entered +
                          pallet position &1 that is greater than +
                          the maximum pallet position &2. &N +
                          Recovery  . . . :   Change the value +
                          entered for the pallet position to a +
                          value less than or equal to &2.') SEV(30) +
                          FMT((*DEC 3 0) (*DEC 3))
             ENDDO

/*  RC20012 License not found in tracking files. */

             CHGVAR     VAR(&MSGID) VALUE('RC20012')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not found in tracking +
                          files.') SECLVL('Cause . . . :   User +
                          scanned license &1 and it was not found +
                          in the License Tracking files. &N +
                          Recovery  . . . :   Scan another license +
                          on the pallet located in slot &2. Then +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 15 0) (*CHAR 12))
             ENDDO

/*  RC20013 License not found in scanned slot. */

             CHGVAR     VAR(&MSGID) VALUE('RC20013')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not found in scanned slot +
                          &2.') SECLVL('Cause . . . :   License &1 +
                          scanned is not located in slot &2. &N +
                          Recovery  . . . :   Scan a new license +
                          that is located in slot &2. Then try your +
                          request again.') SEV(30) FMT((*CHAR 15 0) +
                          (*CHAR 12))
             ENDDO

/*  RC20014 No room in pushback slot. Merge item onto pallet. */

             CHGVAR     VAR(&MSGID) VALUE('RC20014')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          room in pushback slot. Merge item onto +
                          pallet.') SECLVL('Cause . . . :   There +
                          is no room in pushback slot. &N Recovery  +
                          . . . :   Merge item onto existing pallet +
                          or scan a new slot. Then try your request +
                          again.') SEV(30)
             ENDDO

/*  RC20015 Scan license on front pallet in slot.                          */

             CHGVAR     VAR(&MSGID) VALUE('RC20015')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Scan +
                          license on front pallet in slot &2.') +
                          SECLVL('Cause . . . :   License &1 +
                          scanned is located in pallet position +
                          &3 in slot &2. &N Recovery  . . . :   +
                          Scan a license that is located in +
                          position 1 in slot &2. Then try your +
                          request again.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 12) (*DEC 3 0))
             ENDDO

/*  RC20016 Scan license on pallet on floor.                               */

             CHGVAR     VAR(&MSGID) VALUE('RC20016')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Scan +
                          license on pallet on floor.') +
                          SECLVL('Cause . . . :   License &1 +
                          scanned is located in pallet position &3 +
                          in slot &2. &N Recovery  . . . :   Scan a +
                          license that is located on floor to begin +
                          putaway process. Then try your request +
                          again.') SEV(30) FMT((*CHAR 15) (*CHAR +
                          12) (*DEC 3 0))
             ENDDO

/*  RC20017 Invalid slot, virtual slot.        */

             CHGVAR     VAR(&MSGID) VALUE('RC20017')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot, virtual slot.') +
                          SECLVL('Cause . . . +
                          . . :   The scanned slot is a virtual slot. +
                          Cannot scan a virtaul slot. +
                          &N Recovery  . . . :   +
                          Scan base slot for location.') +
                          SEV(30)
             ENDDO

/*  RC20018 Can not put in pick slot */

             CHGVAR     VAR(&MSGID) VALUE('RC20018')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Can not put in pick slot.') SECLVL('Cause +
                          . . . :   Special item must be +
                          put in overflow slot. +
                          &N Recovery  . . . :   +
                          Put product in overflow slot') +
                           SEV(30)
             ENDDO

/*  RC20019 License already scanned in. */

             CHGVAR     VAR(&MSGID) VALUE('RC20019')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License already scanned in by &2.') +
                          SECLVL('Cause . . . . . :   License +
                          number &1 has already been scanned in by +
                          user &2. &N Recovery  . . . :   Verify +
                          the number scanned in is correct or scan +
                          a new number and try your request +
                          again.') SEV(30) FMT((*CHAR 15) (*CHAR 10))
             ENDDO

/*  RC20020 Slot not in &2 section. */

             CHGVAR     VAR(&MSGID) VALUE('RC20020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          not in &2 section.') SECLVL('Cause . . . +
                          . . :   Slot-&1 is not in the same +
                          section as the item (&3). &N Recovery  . +
                          . . :   Scan a new slot that is in the &2 +
                          section and try your request again.') +
                          SEV(30) FMT((*CHAR 12) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  RC20021 License deleted */

             CHGVAR     VAR(&MSGID) VALUE('RC20021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 is deleted and cannot be +
                          used') SECLVL('Cause . . . . . :   +
                          License &1 is deleted. &N Recovery  . . . +
                          :   Contact receiving clerk.') SEV(30) +
                          FMT((*CHAR 15))
             ENDDO

/*  RC20022 License not found in LICACTIVE */

             CHGVAR     VAR(&MSGID) VALUE('RC20022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not found in LICACTIVE +
                          file') SECLVL('Cause . . . . . :   +
                          License &1 was not found in the LICACTIVE +
                          file. &N Recovery  . . . :   Verify +
                          correct license was scanned, then contact +
                          tech suppor.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  RC20023 License not found in LICINFO */

             CHGVAR     VAR(&MSGID) VALUE('RC20023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not found in LICINFO +
                          file') SECLVL('Cause . . . . . :   +
                          License &1 was not found in the LICINFO +
                          file. &N Recovery  . . . :   Verify +
                          correct license was scanned, then contact +
                          tech suppor.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  RC20024 License not in a RCV or STG location */

             CHGVAR     VAR(&MSGID) VALUE('RC20024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not in receiving dock or +
                          stage location') SECLVL('Cause . . . . . +
                          :   License &1 is in slot &2. For putaway +
                          a license must reside in a receiving dock +
                          (RCV) or stage (STG) location. &N +
                          Recovery  . . . :   Use a the transfer +
                          program to move this license.') SEV(30) +
                          FMT((*CHAR 15) (*CHAR 12))
             ENDDO

/*  RC20025 License slot not found */

             CHGVAR     VAR(&MSGID) VALUE('RC20025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License slot &2 not found for +
                          license &1') SECLVL('Cause . . . . . :   +
                          The LICACTIVE record for license &1 is +
                          associated with slot &2, but that slot +
                          does not exist. &N Recovery  . . . :   +
                          Contact support.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 12))
             ENDDO

/*  RC20026 License slot not active */

             CHGVAR     VAR(&MSGID) VALUE('RC20026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License slot &2 not active') +
                          SECLVL('Cause . . . . . :   The LICACTIVE +
                          record for license &1 is associated with +
                          slot &2, but that slot has a non-active +
                          status of &3. &N Recovery  . . . :   +
                          Contact support.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 12) (*CHAR 1))
             ENDDO

/*  RC20027 Wrong item found in license slot */

             CHGVAR     VAR(&MSGID) VALUE('RC20027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Wrong item found in license slot +
                          &2') SECLVL('Cause . . . . . :   The +
                          LICACTIVE record for license &1 is +
                          associated with item &3 and slot &2, but +
                          that slot contains item &4 instead. &N +
                          Recovery  . . . :   Contact support.') +
                          SEV(30) FMT((*CHAR 15) (*CHAR 12) (*CHAR +
                          15) (*CHAR 15))
             ENDDO

/*  RC20028 License transaction not found */

             CHGVAR     VAR(&MSGID) VALUE('RC20028')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License transaction &2 not found') +
                          SECLVL('Cause . . . . . :   The LICACTIVE +
                          record for license &1 is associated with +
                          transaction &2, but that transaction was +
                          not found. &N Recovery  . . . :   Contact +
                          support.') SEV(30) FMT((*CHAR 15) (*DEC 7))
             ENDDO

/*  RC20029 License transaction not a putaway transaction */

             CHGVAR     VAR(&MSGID) VALUE('RC20029')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License transaction &2 not a putaway +
                          transaction') SECLVL('Cause . . . . . :   +
                          The LICACTIVE record for license &1 is +
                          associated with transaction &2, but that +
                          transaction is not a putaway transaction. +
                          Instead it has a type of &3. &N Recovery  +
                          . . . :   Contact support.') SEV(30) +
                          FMT((*CHAR 15) (*DEC 7) (*CHAR 6))
             ENDDO

/*  RC20030 Putaway completed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('RC20030')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Lic: &1 +
                          putaway to slot &2.') +
                          SECLVL('Cause . . . . . :   +
                          Lic: &1 successfully transfered to slot +
                          &2.  &N Recovery  . . . :   No recovery.  +
                          This is an informational message.') +
                          SEV(10) FMT((*CHAR 15) (*CHAR 12))
             ENDDO

/*  RL21001 Batch not found. */

             CHGVAR     VAR(&MSGID) VALUE('RL21001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch &1 not found.') SECLVL('Cause +
                          . . . . . :   Batch &1 not found for this +
                          warehouse. &N Recovery  . . . :   Enter a +
                          valid batch number and try your request +
                          again.') SEV(30) FMT((*DEC 7))
             ENDDO

/*  RL21002 Batch is not a receiving batch. */

             CHGVAR     VAR(&MSGID) VALUE('RL21002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch &1 is not a receiving batch.') +
                          SECLVL('Cause . . . . . :   Batch &1 is +
                          type &2 instead of *RCVLBL. &N Recovery  +
                          . . . :   Enter a receiving batch +
                          number.') SEV(30) FMT((*DEC 7) (*CHAR 8))
             ENDDO

             RETURN
             ENDPGM
