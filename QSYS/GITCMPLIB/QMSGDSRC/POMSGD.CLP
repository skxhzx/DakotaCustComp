/*------------------------------------------------------------------*/
/*  English Version (Spanish version is POMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  POMSGD      Create PIRMSGF Message Descriptions POpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*  02/19/98  RH  4.09  Add PO23601 message.                       */
/*  12/07/98  RH  4.10  Add PO14404 message.                       */
/*  10/11/99  DAS 4.13  Add PO14405 message.                       */
/*  10/16/00  DAS 4.14  Add PO11001 message.                       */
/*  12/15/00  HNK 4.15  Add PO11402 message.                       */
/*  03/06/01  RH  4.15a Add PO13229 message.                       */
/*  11/26/01  MLB 4.16  Add PO13230 message.                        */
/*  11/26/01  MLB 4.16  Add PO13231 message.                        */
/*  11/26/01  MLB 4.16  Add PO13232 message.                        */
/*  11/27/01  MLB 4.16  Add PO13233 message.                        */
/*  11/28/01  MLB 4.16  Add PO13234 message.                        */
/*  12/01/01  MLB 4.16  Add PO13235 message.                        */
/*  12/21/01  MLB 4.16  Add PO13236 message.                        */
/*                      Add PO13237 message.                        */
/*                      Add PO13238 message.                        */
/*                      Add PO13239 message.                        */
/*                      Add PO13240 message.                        */
/*                      Add PO13241 message.                        */
/*  02/06/03  HNK CBIb  Add PO11002 message.                        */
/*  02/14/03  MLB 4.16  Add PO13242 message.                        */
/*  04/02/03  MLB 4.17a Add PO13243 message.                        */
/*  04/03/03  MLB 4.17a Add PO13244 message.                        */
/*  04/03/03  MLB 4.17a Add PO13245 message.                        */
/*  04/03/03  MLB 4.17a Add PO13246 message.                        */
/*  04/09/03  RH  4.17b Add PO20035 message.                        */
/*  05/27/03  RH  4.17c Add PO23201 message.                        */
/*  01/06/04  RH  4.17d Add PO20036 message.                        */
/*  06/29/04  MLB 4.17e Add PO13247 message.                        */
/*                                                                  */
/*  11/10/04  MLB 5.00  Replaced msg text on message id's with      */
/*                      correct msg text on PO13230-PO13234.        */
/*                      Added new msgid: PO13248.                   */
/*  09/24/01  DAS 5.00  Original change was V4.16 missed in update  */
/*                      Revised MSG of PO13228 and PO13229.         */
/*                      Added identifier to end of message.         */
/*  10/21/05  DAS 5.00  Added PO11003, PO11004, PO12001 and PO12002.*/
/*  03/14/07  RH  5.10a Add msg PO20001 like PO13231 to use F10     */
/*                      override not F20.                           */
/*  10/09/07  MLB 5.10b Add PO13249 message.                        */
/*  01/13/08  LMC 5.10C Add PO13250 message.                        */
/*  06/18/08  RH  5.20A Add PO23202 message.                        */
/*  10/17/08  RH  5.20b Add PO12004 message.                        */
/*  10/10/11  GJA 6.40a Add PO23210 message.                        */
/*  10/10/11  GJA 6.40b Add PO23211 message.                        */
/*  10/10/11  GJA 6.40c Add PO23212 message.                        */
/*  09/05/12  LMC 6.40d Add PO23701 message.                        */
/*                      Add PO23702 message.                        */
/*  07/08/13  LMC 6.50A Add PO12005 message.                        */
/*  10/25/13  LMC 6.50b Add PO23203 message.                        */
/*  01/27/14  LMC 6.50C Add PO13701 message.                        */
/*  05/08/17  MLB 7.10  Add PO23215 message.                        */
/*  05/08/17  RH  7.10A                                             */
/*            Revised MSG of PO13243, PO13228, PO13229, PO23210     */
/*            PO13231,                                              */
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

/*  PO11001 Cannot mark PO for export. Detail lines not marked. */

             CHGVAR     VAR(&MSGID) VALUE('PO11001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot mark PO for export - Some +
                          detail lines not marked.') +
                          SECLVL('''Cause . . . . . :   A PO can +
                          not be marked for export until all detail +
                          lines have been marked. &N Recovery  . . +
                          . :   Work with the PO detail and make +
                          sure all lines have been marked. Ones +
                          that are not marked can be marked by +
                          receiving them or by using option ''X'' +
                          to manually mark lines that were not +
                          received.''') SEV(30)
             ENDDO

/*  PO11002 Cannot mark PO for export. Lumper info not entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO11002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot mark PO for export - Lumper +
                          info not entered.') SECLVL('Cause . . . . +
                          . :   A PO can not be marked for export +
                          until lumper info have been entered. &N +
                          Recovery  . . . :   Take option 15 and +
                          enter Lumper information.') SEV(30)
             ENDDO

/*  PO11003 HACCP info not allowed for PO */

             CHGVAR     VAR(&MSGID) VALUE('PO11003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('HACCP info not allowed for PO &1') +
                          SECLVL('Cause . . . . . :   None of the +
                          items on PO &1 allow HACCP information to +
                          be entered. &N Recovery  . . . :   +
                          Identify the item that should allow HACCP +
                          information and change the category of +
                          the item to one that allows HACCP +
                          information to be entered.') SEV(30) +
                          FMT((*CHAR 9))
             ENDDO

/*  PO11004 HACCP info must be entered before receiving item */

             CHGVAR     VAR(&MSGID) VALUE('PO11004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('HACCP info must be entered before +
                          working with detail') SECLVL('Cause . . . +
                          . . :   HACCP information has not been +
                          entered for PO &1. However, the category +
                          for item &2 forces HACCP information to +
                          be entered for the PO.  &N Recovery  . . +
                          . :   Either enter the HACCP information +
                          or change the category of item &2. ') +
                          SEV(30) FMT((*CHAR 9) (*CHAR 15))
             ENDDO

/*  PO11401 Cannot delete PO marked as 'Ready for export'. */

             CHGVAR     VAR(&MSGID) VALUE('PO11401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete a PO that is ready for +
                          export.') SECLVL('Cause . . . . . :   +
                          This PO is marked as ready for export. &N +
                          Recovery  . . . :   Unmark the PO and try +
                          your request again.') SEV(30)
             ENDDO

/*  PO11402 Cannot delete PO - Some items received.        */

             CHGVAR     VAR(&MSGID) VALUE('PO11402')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete PO - some items +
                          received.') SECLVL('Cause . . . . . :   +
                          Some items are already received against +
                          this PO. &N Recovery  . . . :   Contact +
                          your DP manager.') SEV(30)
             ENDDO

/*  PO11621 Printing receiving document for P.O. */

             CHGVAR     VAR(&MSGID) VALUE('PO11621')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Printing receiving document for P.O. +
                          &1.') SEV(00) FMT((*DEC 9 0))
             ENDDO

/*  PO12001 HACCP info not allowed for item */

             CHGVAR     VAR(&MSGID) VALUE('PO12001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('HACCP info not allowed for item &1') +
                          SECLVL('Cause . . . . . :   The category +
                          for item &1 does not allow HACCP +
                          information to be entered. &N Recovery  . +
                          . . :   Change the category information +
                          for item &1.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO12002 HACCP info must be entered before receiving item */

             CHGVAR     VAR(&MSGID) VALUE('PO12002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('HACCP info must be entered before +
                          receiving item') SECLVL('Cause . . . . . +
                          :   HACCP information has not been +
                          entered for item &1, but the category for +
                          item &1 identifies that HACCP information +
                          must be entered before receiving can take +
                          place.  &N Recovery  . . . :   Either +
                          enter the HACCP information before +
                          receiving or change the item''s category. +
                          ') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO12003 HACCP HDR info must be entered before receiving item */

             CHGVAR     VAR(&MSGID) VALUE('PO12003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('HACCP header info must be entered +
                          before receiving item') SECLVL('Cause . . +
                          . . . :   HACCP header information has +
                          not been entered for the category of 1 or +
                          more items on PO &1.  &N Recovery  . . . +
                          :   Use Option 11 to enter the HACCP +
                          header information for the item category +
                          or use the Item Category Maintenance +
                          option to set the HACCP header +
                          information flag to ''No'' before +
                          receiving the item.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO12004 Stuffit receiving not allowed for item */

             CHGVAR     VAR(&MSGID) VALUE('PO12004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Stuffit receiving not allowed for +
                          item') SECLVL('Cause . . +
                          . . . :   Item is not defined for +
                          Stuffit receiving, contact buyer. +
                          Recovery  . . . +
                          :   Press F12, contact buyer to change +
                          item.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO12221 Special order already exists for this item. */

             CHGVAR     VAR(&MSGID) VALUE('PO12221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          currently exists as a special order.') +
                          SECLVL('Cause . . . . . :   This item has +
                          already been defined as a special order. +
                          &N Recovery  . . . :   Enter an item that +
                          is not a special order or remove the +
                          existing special order.') SEV(30)
             ENDDO

/*  PO12401 Cannot delete a line, if some qty received.    */

             CHGVAR     VAR(&MSGID) VALUE('PO12401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete a line, if some +
                          quantity is received.') SECLVL('Cause . . +
                          . . . :   Quantity has been received for +
                          this item. &N Recovery  . . . :   No +
                          recovery.') SEV(30)
             ENDDO

/*  PO13212 Item and slot types do not match. */

             CHGVAR     VAR(&MSGID) VALUE('PO13212')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          and slot types do not match.') +
                          SECLVL('Cause . . . . . :   An item can +
                          only be stored in a slot that is of the +
                          same type (PIR/Fixed). The item type (&1) +
                          does not match the slot type (&2). &N +
                          Recovery  . . . :   Select a slot that is +
                          the same type as the item.') SEV(30) +
                          FMT((*CHAR 5) (*CHAR 5))
             ENDDO

/*  PO13214 Fixed slot is reserved for a different item. */

             CHGVAR     VAR(&MSGID) VALUE('PO13214')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Fixed slot is reserved for item +
                          &1.') SECLVL('Cause . . . . . :   The +
                          slot you entered is reserved for a +
                          different item (&1). &N Recovery  . . . +
                          :   Select either an empty slot or one +
                          that is already occupied by item &1.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO13221 Slot is already occupied with a different item. */

             CHGVAR     VAR(&MSGID) VALUE('PO13221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          is already occupied with a different +
                          item.') SECLVL('Cause . . . . . :   The +
                          slot you entered already contains item +
                          &1. &N Recovery  . . . :   Enter a +
                          different slot or use the Inventory +
                          Adjustment program to clear the slot.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO13222 This item has already been received in full. */

             CHGVAR     VAR(&MSGID) VALUE('PO13222')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          item has already been received in full.') +
                          SECLVL('Cause . . . . . :   The quantity +
                          received for this item is greater than or +
                          equal to the quantity ordered. &N +
                          Recovery  . . . :   Verify that you are +
                          not duplicating a previous entry and then +
                          enter the quantity received.') SEV(00)
             ENDDO

/*  PO13223  Total quantity received is greater than qty ordered. */

             CHGVAR     VAR(&MSGID) VALUE('PO13223')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Total quantity received is +
                          greater than quantity ordered.') +
                          SECLVL('Cause . . . . . :   The total +
                          quantity received (&1) is greater than +
                          the quantity ordered (&2). &N Recovery  . +
                          . . :   This is only a warning, no action +
                          is necessary.') SEV(00) FMT((*DEC 5 0) +
                          (*DEC 5 0))
             ENDDO

/*  PO13224  Slot does not exist within entered department. */

             CHGVAR     VAR(&MSGID) VALUE('PO13224')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Department/Slot combination does not +
                          exist.') SECLVL('Cause . . . . . :   The +
                          slot number entered does not exist within +
                          the entered department. &N Recovery  . . +
                          . :   Enter a correct department/slot +
                          combination.') SEV(30)
             ENDDO

/*  PO13225 Item and slot designation areas do not match */

             CHGVAR     VAR(&MSGID) VALUE('PO13225')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          and slot designation areas do not +
                          match.') SECLVL('Cause . . . . . :   An +
                          item can only be stored in a slot with a +
                          matching designation area. The item +
                          designation area (&1) and the slot +
                          designation area (&2) do not match. &N +
                          Recovery  . . . :   Select a slot that +
                          has the same designation area as the +
                          item.') SEV(30) FMT((*CHAR 5) (*CHAR 5))
             ENDDO

/*  PO13226 Cannot receive an item, if PO is 'Ready for export'. */

             CHGVAR     VAR(&MSGID) VALUE('PO13226')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot receive an item, if PO is +
                          ready for export.') SECLVL('Cause . . . . +
                          . :   This PO is marked as ready for +
                          export. &N Recovery  . . . :   Unmark the +
                          PO and try your request again.') SEV(30)
             ENDDO

/*  PO13227 Slot must be a verified slot or contain item to place item in it. */

             CHGVAR     VAR(&MSGID) VALUE('PO13227')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          slot entered for putaway must be verified +
                          first.') SECLVL('''Cause . . . . . :   +
                          The slot selected has a status of ''Z''. +
                          &N Recovery  . . . :   Verify the slot +
                          and try again or enter a different +
                          slot.''') SEV(30)
             ENDDO

/*  PO13228 Item cannot be accepted.                     */

             CHGVAR     VAR(&MSGID) VALUE('PO13228')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

/* 710a      ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item + */
/* 710a                   cannot be accepted - Mfg date') +            */
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          cannot be accepted-Mfg date short Dist-User days') +
                          SECLVL('Cause . . . . . :   Item has a +
                          Mfg shelf life days of(&1). With Mfg date +
                          being (&2), the product will expire on +
                          (&3).  The latest acceptable date to +
                          receive is (&4) given that the +
                          distributor needs &5 days to sell and the +
                          end user needs &6 days to sell. &N +
                          Recovery  . . . :   Do not receive the +
                          item.  Item may be received by changing +
                          the Mfg shelf life days, Dist days and +
                          User days, but the item will have to be +
                          sold faster.') SEV(30) FMT((*DEC 3) (*DEC +
                          7) (*DEC 7 0) (*DEC 7 0) (*DEC 3 0) (*DEC +
                          3 0))
             ENDDO

/*  PO13229 Item cannot be accepted. Use by date         */

             CHGVAR     VAR(&MSGID) VALUE('PO13229')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

/* 710a      ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +   */
/* 710a                   cannot be accepted - Use by date') +           */
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          cannot be accepted - Short Dist-User days to sell') +
                          SECLVL('Cause . . . . . :   Item has a +
                          use by date of(&1). The distributor needs +
                          &2 days to sell and the end user needs &3 +
                          days to sell. The item must be sold by +
                          (&4). &N Recovery  . . . :   Do not +
                          receive the item.  Item may be received +
                          by changing the Dist days and User days, +
                          but the item will have to be sold +
                          faster.') SEV(30) FMT((*DEC 7) (*DEC 3 0) +
                          (*DEC 3 0) (*DEC 7 0))
             ENDDO

/*  PO13230 Item cannot be accepted. Expiration date     */

             CHGVAR     VAR(&MSGID) VALUE('PO13230')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

/* 710a      ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item + */
/* 710a                   cannot be accepted - Expiration date') +     */
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          cannot be accepted - Earlier Exp-newer +
                          date in whse') +
                          SECLVL('Cause . . . . . :   Cannot accept +
                          item that has an ealier expiration date +
                          (&1) than existing overflow expiration +
                          date (&2). &N Recovery  . . . :   None. +
                          You are not allowed to receive the +
                          item.') SEV(30) FMT((*DEC 9) (*DEC 9 0))
             ENDDO

/*  PO13231 Warning: Ealier expiration date     */

             CHGVAR     VAR(&MSGID) VALUE('PO13231')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

/*  710a     ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +         */
/*  710a                  MSG('Warning: Earlier expiration date. +   */
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Earlier exp-newer +
                          date in whse  Press F20 to override') +
                          SECLVL('Cause . . +
                          . . . :   The expiration date entered +
                          (&1) comes before an existing overflow +
                          expiration date (&2). &N Recovery  . . . +
                          :   Press F20 to override the warning and +
                          receive the item.') SEV(30) FMT((*DEC 9) +
                          (*DEC 9 0))
             ENDDO

/*  PO13232 Item cannot be accepted. Calculated expiration date */

             CHGVAR     VAR(&MSGID) VALUE('PO13232')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          cannot be accepted - Calculated +
                          expiration date') SECLVL('Cause . . . . . +
                          :   Cannot accept item that has an ealier +
                          expiration date (&1) than existing +
                          overflow expiration date (&2). The +
                          expiration date was calculated with the +
                          following equation: Mfr Date + Mfr Shelf +
                          Life Days - User Days to Sell. &N +
                          Recovery  . . . :   None. You are not +
                          allowed to receive the item.') SEV(30) +
                          FMT((*DEC 9) (*DEC 9 0))
             ENDDO

/*  PO13233 Warning: Ealier calculated expiration date     */

             CHGVAR     VAR(&MSGID) VALUE('PO13233')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Earlier calculated +
                          expiration date. Press F20 to override') +
                          SECLVL('Cause . . . . . :   The +
                          expiration date entered (&1) comes before +
                          an existing overflow expiration date +
                          (&2). The expiration date was calculated +
                          with the following equation: Mfr Date + +
                          Mfr Shelf Life Days - User Days to Sell. +
                          &N Recovery  . . . :   Press F20 to +
                          override the warning and receive the +
                          item.') SEV(30) FMT((*DEC 9) (*DEC 9 0))
             ENDDO

/*  PO13234 CW must be zero when receiving avg. */

             CHGVAR     VAR(&MSGID) VALUE('PO13234')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('CW +
                          must be zero when doing average for +
                          "First time only" CW entry.') +
                          SECLVL('''Cause . . . . . :   The +
                          Receiving catch weight option is set to +
                          "First time only". Because of this, when +
                          the average flag is set to ''Y'', the +
                          catch weight entry field must be set to +
                          zero. &N Recovery  . . . :   Change the +
                          catch weight entry to zero.''') SEV(30)
             ENDDO

/*  PO13235 Individual p/o not removed from Super P/O. */

             CHGVAR     VAR(&MSGID) VALUE('PO13235')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Individual p/o-&1 not removed from +
                          Super P/O-&2.') SECLVL('Cause . . . . . +
                          :   No further information.&N Recovery  . +
                          . . :   Contact your D.P. manager.') +
                          SEV(30) FMT((*CHAR 9) (*CHAR 9))
             ENDDO

/*  PO13236 Position to x not found on Super P/O. */

             CHGVAR     VAR(&MSGID) VALUE('PO13236')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Position to-&1 &3 not found on Super +
                          P/O-&2.') SECLVL('Cause . . . . . :   +
                          Position to-&1 with value of &3 was +
                          greater than the &1s on Super P/O-&2.  &N +
                          Recovery  . . . :   Change your position +
                          to-&1 to something less than &3 and +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 4) (*CHAR 9) (*CHAR 15))
             ENDDO

/*  PO13237 Option 13=Work w/Super P/O not allowed.      */

             CHGVAR     VAR(&MSGID) VALUE('PO13237')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option 13=Work w/Super P/O not +
                          allowed on individual p/o''s.') +
                          SECLVL('Cause . . . . . :   User has +
                          selected the option to work with Super +
                          P/O. This option is not valid for +
                          individual purchase orders. A Super P/O +
                          is identified by a p/o number beginning +
                          with SPxxxxxxx where x=a unique number. +
                          &N Recovery  . . . :   Remove the option +
                          13=Work with Super P/O from the +
                          individual purchase order. Then position +
                          to the purchase orders beginning with SP. +
                          Then try your request again.') SEV(30) +
                          FMT(*NONE)
             ENDDO

/*  PO13238 Option 8=Mark not allowed for Individual P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13238')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option 8=Mark for export not allowed +
                          for individual p/o''s attached to a Super +
                          P/O.') SECLVL('Cause . . . . . :   User +
                          has selected an individual purchase order +
                          to be marked for export. This is not +
                          allowed for purchase orders attached to a +
                          Super P/O. &N Recovery  . . . :   Remove +
                          the option from the individual p/o. Then +
                          mark the Super P/O for export. If the +
                          individual p/o needs to be exported +
                          immediately, remove the p/o from the +
                          Super P/O. Then try your request again.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PO13239 Option 9=UnMark not allowed for individual P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13239')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option 9=UnMark not allowed for +
                          individual p/o''s attached to a Super +
                          P/O.') SECLVL('Cause . . . . . :   User +
                          has selected an individual purchase order +
                          to be unmarked. This is not allowed for +
                          purchase orders attached to a Super P/O. +
                          &N Recovery  . . . :   Remove this option +
                          from the individual p/o. Then unmark the +
                          Super P/O. If this p/o is not ready for +
                          export, remove it from the Super P/O. +
                          Then use 9=UnMark to keep p/o from being +
                          exported unit it is ready. Then try your +
                          request again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PO13240 Option 11=HACCP Info not allowed for Super P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13240')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option 11=HACCP info not allowed for +
                          Super P/O.') SECLVL('Cause . . . . . :   +
                          User has selected a Super P/O to enter +
                          HACCP info. This is not allowed for Super +
                          P/O''s. &N Recovery  . . . :   Remove +
                          this option from the Super P/O. Select an +
                          individual p/o that is not in the format +
                          of SPxxxxxxx where x=a unique number. +
                          Then try your request again.') SEV(30) +
                          FMT(*NONE)
             ENDDO

/*  PO13241 P/O-XXXXXXXXX Removed from Super P/O. */

             CHGVAR     VAR(&MSGID) VALUE('PO13241')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('P/O-&1 removed successfully from +
                          Super P/O-&2.') SECLVL('Cause . . . . . +
                          :   User selected individual purchase +
                          order-&1 to be removed from Super P/O-&2. +
                          &N Recovery  . . . :   If this purchase +
                          order was removed in error, then use +
                          F6=Add ind p/o''s to re-add the purchase +
                          order back to the Super P/O. Otherwise, +
                          nothing needs to be done.') SEV(00) +
                          FMT((*CHAR 9) (*CHAR 9))
             ENDDO

/*  PO13242 Super P/O at Export status. Additions not allowed. */

             CHGVAR     VAR(&MSGID) VALUE('PO13242')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Super P/O-&1 marked for Export. +
                          Additions not allowed.') SECLVL('Cause . +
                          . . . . :   User selected F6=Ind. p/o to +
                          add more individual p/o''s to the Super +
                          P/O. Super P/O-&1 is at Ready to Export +
                          status and additions are not allowed. &N +
                          Recovery  . . . :   User can do one of +
                          the following options: 1.) Exit from this +
                          Super P/O and select a new Super P/O that +
                          is not at Ready to Export status. 2.) +
                          Select option 9=Unmark for this Super P/O +
                          and then return to add individual p/o(s). +
                          3.) Create new Super P/O and add +
                          individual p/o''s to the new Super P/O.') +
                          SEV(30) FMT((*CHAR 9))
             ENDDO

/*  PO13243 Item cannot be accepted. expiration date # of days out   */

             CHGVAR     VAR(&MSGID) VALUE('PO13243')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

 /*  710a    ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item + */
 /*  710a                 cannot be accepted - Expiration date') +     */
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          cannot be accepted - Exp date-# of days out') +
                          SECLVL('Cause . . . . . :   Item has an +
                          expiration date of(&1). The date can +
                          be &2 # of days out. +
                          &N Recovery  . . . :  Do not +
                          receive the item.  Item may be received +
                          by changing the # of Days Out.') +
                          SEV(30) FMT((*DEC 7) (*DEC 3 0))
             ENDDO

/*  PO13244 PO Exception code not entered.                                    */

             CHGVAR     VAR(&MSGID) VALUE('PO13244')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('PO +
                          Exception code not entered.') +
                          SECLVL('Cause . . . . . :   PO Exception +
                          code was not entered with exception +
                          quantities. &N Recovery  . . . :  Enter a +
                          valid exception code or press F4=Prompt +
                          to display a list of valid exception +
                          codes. Then try your request again.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PO13245 PO Exception quantities not entered.                             */

             CHGVAR     VAR(&MSGID) VALUE('PO13245')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('PO +
                          Exception quantity not entered with +
                          Exception code &1.') SECLVL('Cause . . . +
                          . . :   No quantities were entered with +
                          PO Exception code &1. &N Recovery  . . . +
                          :  Enter positive quantities with a valid +
                          exception code. Then try your request +
                          again.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PO13246 Total quantity is greater than quantity ordered.                 */

             CHGVAR     VAR(&MSGID) VALUE('PO13246')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Total quantity &1.&2.&3 is greater +
                          than quantity ordered &4.&5.&6.') +
                          SECLVL('Cause . . . . . :   User has +
                          entered an total quantity that is greater +
                          than the quantity ordered. The total +
                          quantity includes the quantity received. +
                          &N Recovery  . . . :  Enter a quantity +
                          that is less than the quantity ordered or +
                          press F20=Override warning to accept +
                          quantity entered. Then try your request +
                          again.') SEV(30) FMT((*DEC 5) (*DEC 5) +
                          (*DEC 5) (*DEC 5) (*DEC 5) (*DEC 5))
             ENDDO

/*  PO13247 Super P/O at wrong status or not found. P/O not added.           */

             CHGVAR     VAR(&MSGID) VALUE('PO13247')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Super P/O-&1 at wrong status or not +
                          found. P/O-&2 not added.') SECLVL('Cause  +
                          . . . . . Super P/O-&1 may have been +
                          marked for export or someone has deleted +
                          the Super P/O. Once a Super P/O is marked +
                          for export, additions are no longer +
                          allowed. &N Recovery . . . . Return to +
                          Purchase Order Maintenance and unmark +
                          Super P/O for export, then return to add +
                          individual p/o''s and proceed normally. +
                          If Super P/O no longer exists, press +
                          F7=Super P/O to create new Super P/O and +
                          proceed normally.') SEV(30) FMT((*CHAR +
                          10) (*CHAR 10) (*DEC 5) (*DEC 5) (*DEC 5) +
                          (*DEC 5))
             ENDDO

/*  PO13248 Option 70=Export p/o not allowed for individual p/o's on Super */

             CHGVAR     VAR(&MSGID) VALUE('PO13248')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option 70=Export p/o not allowed for +
                          individual p/o''s attached to Super +
                          P/O.') SEV(30) FMT(*NONE)
             ENDDO


/*  PO14221  Quantity entered greater than slot quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PO14221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Adjustment quantity is greater than +
                          slot quantity.') SECLVL('Cause . . . . . +
                          :   The adjustment quantity entered (&1) +
                          is greater than the slot quantity (&2). +
                          &N Recovery  . . . :   Enter an +
                          adjustment quantity that is less than or +
                          equal to the slot quantity.') SEV(30) +
                          FMT((*DEC 5 0) (*DEC 5 0))
             ENDDO

/*  PO13249 Option 17=P/O Total Qty/Wgt not allowed for Super P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13249')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option 17=P/O Total Qty/Wgt not allowed for +
                          Super P/O.') SECLVL('Cause . . . . . :   +
                          User has selected a Super P/O to display Total Qty/ +
                          Wgt info. This is not allowed for Super +
                          P/O''s. &N Recovery  . . . :   Remove +
                          this option from the Super P/O. Select an +
                          individual p/o that is not in the format +
                          of SPxxxxxxx where x=a unique number. +
                          Then try your request again.') SEV(30) +
                          FMT(*NONE)
             ENDDO
/*  PO13250 CMD11 - MFR Decipher program - Date sensitive items only */

             CHGVAR     VAR(&MSGID) VALUE('PO13250')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('CMD11 is only allowed for Date +
                          Sensitive Items.') SECLVL('Cause . . . . +
                          . :   Item being received is not date +
                          sensitive.') SEV(30) FMT(*NONE)
             ENDDO

/*  PO14222  Slot does not contain item. */

             CHGVAR     VAR(&MSGID) VALUE('PO14222')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          does not contain item &1.') SECLVL('Cause +
                          . . . . . :   The slot you entered does +
                          not contain item &1. &N Recovery  . . . +
                          :   Enter a slot that &1 occupies.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO14223  Quantity entered greater than quantity received. */

             CHGVAR     VAR(&MSGID) VALUE('PO14223')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Adjustment quantity is greater than +
                          quantity received.') SECLVL('Cause . . . +
                          . . :   The adjustment quantity entered +
                          (&1) is greater than the quantity +
                          received (&2). &N Recovery  . . . :   +
                          Enter an adjustment quantity that is less +
                          than or equal to the quantity received.') +
                          SEV(30) FMT((*DEC 5 0) (*DEC 5 0))
             ENDDO

/*  PO14401 Record selected does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PO14401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          transaction record does not exist.') +
                          SECLVL('Cause . . . . . :   The record +
                          you selected could not be found in the +
                          PIRTRAN file.  &N Recovery  . . . :   +
                          Contact your D.P. manager.') SEV(40)
             ENDDO

/*  PO14402 Cannot delete closed transaction. */

             CHGVAR     VAR(&MSGID) VALUE('PO14402')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete closed transaction.') +
                          SECLVL('Cause . . . . . :   The record +
                          you selected could not be deleted because +
                          it is closed.  &N Recovery  . . . :   No +
                          recovery.') SEV(40)
             ENDDO

/*  PO14403 Cannot delete transactions, if PO is ready to export. */

             CHGVAR     VAR(&MSGID) VALUE('PO14403')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete transaction, if the PO +
                          is ready to export.') SECLVL('Cause . . . +
                          . . :   The PO for this transaction is +
                          ready to export. &N Recovery  . . . :   +
                          Unmark the PO and try your request +
                          again.') SEV(30)
             ENDDO

/*  PO14404 Cannot delete transaction, transaction qty allocated. */

             CHGVAR     VAR(&MSGID) VALUE('PO14404')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete transaction, if the +
                          transaction qty is already allocated.') +
                          SECLVL('Cause . . . . . : +
                            The quantity for this transaction is +
                          already allocated. &N Recovery  . . . :   +
                          No recovery.') SEV(40)
             ENDDO

/*  PO14405 Cannot delete transaction, Transaction started. */

             CHGVAR     VAR(&MSGID) VALUE('PO14405')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete transaction - +
                          Transaction already started.') +
                          SECLVL('Cause . . . . . : The transaction +
                          has already been started by another user. +
                          &N Recovery  . . . :   Have user exit the +
                          transaction and try the request again.') +
                          SEV(30)
             ENDDO

/*  PO15021  P.O. number must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO15021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('P.O. +
                          number must be entered.') SECLVL('Cause . +
                          . . . . :   The P.O. number is manditory +
                          for receiving. &N Recovery  . . . :   +
                          Enter a P.O. number and continue.') SEV(30)
             ENDDO

/*  PO31521 Receiving document has been printed. */

             CHGVAR     VAR(&MSGID) VALUE('PO31521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Receiving document has been +
                          printed.') SEV(00)
             ENDDO

/*  PO20001 Warning: Ealier expiration date    V5.10a */

             CHGVAR     VAR(&MSGID) VALUE('PO20001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Earlier expiration date. +
                          Press F10 to override') SECLVL('Cause . . +
                          . . . :   The expiration date entered +
                          (&1) comes before an existing overflow +
                          expiration date (&2). &N Recovery  . . . +
                          :   Press F10 to override the warning and +
                          receive the item.') SEV(30) FMT((*DEC 9) +
                          (*DEC 9 0))
             ENDDO

/*  PO20022 Dock # must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Dock +
                          must be entered.') SECLVL('Cause . +
                          . . . . :   The Dock number is manditory +
                          for receiving. &N Recovery  . . . :   +
                          Enter the dock number and continue.') SEV(30)
             ENDDO

/*  PO20023 UPC must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('UPC +
                          must be entered.') SECLVL('Cause . +
                          . . . . :   The UPC code is manditory +
                          for receiving. &N Recovery  . . . :   +
                          Enter the UPC code and continue.') SEV(30)
             ENDDO

/*  PO20026 Line not in PO. */

             CHGVAR     VAR(&MSGID) VALUE('PO20026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Line +
                          not in PO.') SECLVL('Cause . . . . . :   +
                          The Line # is not in PO. &N +
                          Recovery  . . . :   Enter a line number +
                          for this PO or F4 for list and +
                          continue.') SEV(30)
             ENDDO

/*  PO20027 Item not in PO. */

             CHGVAR     VAR(&MSGID) VALUE('PO20027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          not in PO.') SECLVL('Cause . . . . . :   +
                          The Item is not in PO. &N Recovery  . . . +
                          :   Enter an item for this PO or F4 for +
                          list and continue.') SEV(30)
             ENDDO

/*  PO20028 Different UPC entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO200289')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Different UPC.') SECLVL('Cause . . . . . :  +
                          Different UPC entered. &N Recovery  . . . +
                          :   Enter UPC code to match UPC to be +
                          verified.') SEV(30)
             ENDDO

/*  PO20029 UPC not on file. */

             CHGVAR     VAR(&MSGID) VALUE('PO20029')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('UPC not on file.') SEV(30)
             ENDDO

/*  PO20030 Line or item must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20030')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Line +
                          or item must be entered.') SECLVL('Cause . +
                          . . . . :   PO line or item is manditory +
                          for receiving. &N Recovery  . . . :   +
                          Enter the PO line or item and continue.') +
                          SEV(30)
             ENDDO

/*  PO20031 UPC already exists for item/vendor. */

             CHGVAR     VAR(&MSGID) VALUE('PO20031')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item/ +
                          Vendor has UPC.') SECLVL('Cause . . . . . : +
                           UPC exists for item/vendor. &N Recovery +
                          . . . :  Enter new item # or check existing +
                          item in UPC file.') SEV(30)
             ENDDO

/*  PO20032 No UPC entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20032')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('NO UPC entered.') SEV(00)
             ENDDO

/*  PO20033 Licnese # required. */

             CHGVAR     VAR(&MSGID) VALUE('PO20033')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          License # required.') SECLVL('Cause . +
                          . . . . :   The License # is manditory +
                          for receiving. &N Recovery  . . . :   +
                          Enter the license #  and continue.') SEV(30)
             ENDDO

/*  PO20034 License already exists. */

             CHGVAR     VAR(&MSGID) VALUE('PO20034')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          License exists.') SECLVL('Cause . . . . . : +
                          License already exists. &N Recovery  . . . +
                          :   Enter new license number.') SEV(30)
             ENDDO

/*  PO20035 Multiple items for UPC. */

             CHGVAR     VAR(&MSGID) VALUE('PO20035')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Multi items for UPC.') SECLVL('Cause : +
                          Multiple items for UPC. &N Recovery  . . . +
                          :   Do not receive using UPC.') SEV(30)
             ENDDO


/*  PO20036 Scanned license too long. */

             CHGVAR     VAR(&MSGID) VALUE('PO20036')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          License too long') SECLVL('Cause . . . . . : +
                          Scanned license too long. &N Recovery  . . . +
                          :   Enter new license number.') SEV(30)
             ENDDO

/*  PO21001 Catch weight average must be 'N' when multiple qtys are entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO21001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Catch +
                          weight average must be N.') SECLVL('Cause . +
                          . . . . :   Multiple quantities and unit of +
                          measures were entered. &N Recovery  . . . :   +
                          Enter N for Catch weight average or receive +
                          only one quantity and unit of measure.') +
                          SEV(30)
             ENDDO

/*  PO23201 UPC code already exists for vendor/item. */

             CHGVAR     VAR(&MSGID) VALUE('PO23201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          UPC exists.') SECLVL('Cause . . . . . : +
                          UPC already exists for vendor-item #. +
                          &N Recovery  . . . +
                          :   Do not enter UPC code.') SEV(30)
             ENDDO

/*  PO23202 Warning: Qty received greater than Qty ordered. */

             CHGVAR     VAR(&MSGID) VALUE('PO23202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Quantity received is +
                          greater than quantity ordered.') +
                          SECLVL('Cause . . . . . :   The quantity +
                          received is greater than +
                          the quantity ordered. &N Recovery  . . . +
                          :   Press F20 to accept the warning and +
                          receive the entered quantity or press F12 +
                          to cancel.') SEV(10)
             ENDDO

/*  PO23601  Total quantity must equal quantity received. */

             CHGVAR     VAR(&MSGID) VALUE('PO23601')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Total &3 quantity must equal quantity +
                          received.') SECLVL('Cause . . . . . : +
                          The total quantity entered for the +
                          pallets (&1) is not equal to the qty +
                          received (&2). &N Recovery . . . :  +
                          Correct the quantity for the pallets.') +
                          SEV(30) FMT((*DEC 7) (*DEC 7) (*CHAR 5))
             ENDDO

/*  PO23210 Not enough shelf life remaining.  6.40a  */

             CHGVAR     VAR(&MSGID) VALUE('PO23210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' Not +
                          enough Shelf Life Remaining') +
                          SECLVL('Cause . . . . . :   Item has an +
                          expiration date of(&4). The date can +
                          be today - &5 dist days out. +
                          &N Recovery  . . . :  Do not +
                          receive the item.  Item may be received +
                          by changing the # of Dist Days Out.') +
                          SEV(30) FMT((*DEC 3 0) (*DEC 7 0)     +
                          (*DEC 7 0) (*DEC 7 0) (*DEC 3 0)      +
                          (*DEC 3 0))
             ENDDO

/*  PO23211 This is a production date, entered date must be a      */
/*          production date previous to today          6.40b       */
             CHGVAR     VAR(&MSGID) VALUE('PO23211')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          This is a production date, entered date +
                          must be a production date previous to +
                          today') SECLVL('Cause . . . . . :   Item +
                          has an expiration date of(&4). The date +
                          must be a date - &5 previous to today. &N +
                          Recovery  . . . :  Do not receive the +
                          item.  Item may be received by changing +
                          the # of Dist Days Out.') SEV(30) +
                          FMT((*DEC 3 0) (*DEC 7 0) (*DEC 7 0)    +
                          (*DEC 7 0) (*DEC 3 0) (*DEC 3 0))
             ENDDO
/*  PO23212 Days exceed total shelf life 6.40c*/
             CHGVAR     VAR(&MSGID) VALUE('PO23212')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Days exceed Total Shelf life') +
                          SECLVL('Cause . . . . . :   Item has an +
                          expiration date of(&4). The date exceeds +
                          total shelf life - &5 . &N Recovery  . . +
                          . :  Do not receive the item.  Item may +
                          be received by changing the # of Dist +
                          Days Out.') SEV(30) FMT((*DEC 3 0) (*DEC +
                          7 0) (*DEC 7 0) (*DEC 7 0) (*DEC 3 0)    +
                          (*DEC 3 0))
             ENDDO
/*  PO23215 PO: &1 inuse on Retalix by &2. Receipt cancelled.        (710 A) */
             CHGVAR     VAR(&MSGID) VALUE('PO23215')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'PO: &1 inuse on Retalix by &2. +
                           &3 cancelled.') +
                          SECLVL('Cause . . . . . :   Receiving has +
                          been cancelled because PO: &1 is being updated +
                          by user &2 on Retalix.  &N Recovery  . . +
                          . :  Contact user &2 and have them complete +
                           their update of PO: &1 so that receiving +
                           can be started. Then try your request again.') +
                           SEV(30) FMT((*CHAR 9) (*CHAR 10) (*CHAR 15))
             ENDDO

/*  PO23701 Mixed Lots on GS1 License scanning  6.40d */
             CHGVAR     VAR(&MSGID) VALUE('PO23701')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Mixed Lots on the +
                          License.') SECLVL('Cause . . . . . :   +
                          Different Lots are being put on one +
                          License. &N Recovery  . . . :   Press F20 +
                          to accept the warning and continue or +
                          press F12 to cancel.') SEV(10)
             ENDDO

/*  PO23702 Mixed Expiration Dates on GS1 License scanning  6.40d */
             CHGVAR     VAR(&MSGID) VALUE('PO23702')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Mixed Expiration Dates on +
                          License.') SECLVL('Cause . . . . . :   +
                          Different Expiration dates are being put +
                          on the same License. &N Recovery  . . . +
                          :   Press F20 to accept the warning and +
                          continue or press F12 to cancel.') SEV(10)
             ENDDO

/*  PO12005 PTI Selection item must have UCI scan at receiving */

             CHGVAR     VAR(&MSGID) VALUE('PO12005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Must +
                          scan UCI to Receive') SECLVL('Cause . . . +
                          . . :   UCI must be scanned at +
                          receiving.') SEV(30) FMT((*CHAR 15 0))
             ENDDO

/*  PO23203 Warning: PTI does not match calculated from barcode */

             CHGVAR     VAR(&MSGID) VALUE('PO23203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: PTI does not match c+
                          alculated PTI from barcode.') +
                          SECLVL('Cause . . . . . :   The PTI enter+
                          ed does not match the +
                          calculated PTI. &N Recovery  . . . +
                          :   Press F20 to accept the warning and +
                          use the PTI entered or press F12 +
                          to cancel.') SEV(10)
             ENDDO


/*  PO13701 Warning: UPC Code is being added */

             CHGVAR     VAR(&MSGID) VALUE('PO13701')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning -UPC does not exist/will be +
                          added.') SECLVL('Cause . . . . . :   The +
                          UPC entered does not exist and will be +
                          added for this item with F20. F12 to +
                          cancel or F20 to accept warning and add +
                          the upc for this item.') SEV(10)
             ENDDO

             RETURN
             ENDPGM
