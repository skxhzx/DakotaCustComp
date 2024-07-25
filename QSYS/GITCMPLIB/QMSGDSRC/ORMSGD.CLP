/*------------------------------------------------------------------*/
/*  English Version (Spanish version is ORMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  ORMSGD      Create PIRMSGF Message Descriptions ORpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  07/03/02  RH  4.16  Add OR12201 message for returns.            */
/*  07/03/02  RH  4.16  Add OR12202 message for returns.            */
/*  12/14/04  RH  5.00  Add OR12203 message for returns.            */
/*  08/20/07  RH  5.10  Add OR12204 message for returns.            */
/*  02/20/09  RH  5.20  Add OR12205 Subs not allowed.               */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  OR13021 Order number must greater than zero. */

             CHGVAR     VAR(&MSGID) VALUE('OR13021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Order number must be greater than +
                          zero.') SECLVL('Cause . . . . . :   Order +
                          number is a required field. Therefore, it +
                          must be greater than zero. &N Recovery  . +
                          . . :   Enter an order number that is +
                          greater than zero.') SEV(30)
             ENDDO

/*  OR11221 Invalide order type entered. */

             CHGVAR     VAR(&MSGID) VALUE('OR11221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Order type must be '' '' or ''T''.') +
                          SECLVL('Cause . . . . . :   Order type is +
                          not '' '' or ''T''.  &N Recovery  . . . +
                          :   Enter '' '' for a normal order or +
                          ''T'' for a transfer.') SEV(30)
             ENDDO

/*  OR12201 Customer order already returned.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'order previously returned.') +
                          SECLVL('Cause . . . . . :   The order +
                          was previously returned. +
                          Recovery  . . . :   Enter a different +
                          order and try again.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO

/*  OR12202 Correspondng item and ordered item must be different.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'corresp. item can not be ordered item.') +
                          SECLVL('Cause . . . . . :   Corresponding +
                          item can not be the same as ordered item. +
                          Recovery  . . . :   Enter a different +
                          correspond. item and try again.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO


/*  OR12203 Disposition code must impact inventory.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'Disposition must impact inv.') +
                          SECLVL('Cause . . . . . :   Disposition +
                          must impact inventory. +
                          Recovery  . . . :   Enter a different +
                          code and try again.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO

/*  OR12204 Item not found on order.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'Item not found on order.') +
                          SECLVL('Cause . . . . . :   Item not +
                          found on order. +
                          Recovery  . . . :   Enter a different +
                          item or order and try again.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO

/*  OR12205 Subs not allowed.         */

             CHGVAR     VAR(&MSGID) VALUE('OR12205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'Substitute not allowed.') +
                          SECLVL('Cause . . . . . :   Substitute +
                          not allowed. +
                          Recovery  . . . :   Substitute item +
                          not allowed.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO


/*  OR13022 Warning: Order number not found in picking file. */

             CHGVAR     VAR(&MSGID) VALUE('OR13022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Order number not found in +
                          picking file.') SECLVL('Cause . . . . . +
                          :   The order number you entered was not +
                          found in the picking file. &N Recovery  . +
                          . . :   Press Enter to use this order +
                          number or enter a new one.') SEV(00)
             ENDDO

/*  OR34021 Batch number not found in picking file. */

             CHGVAR     VAR(&MSGID) VALUE('OR34021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch does not exist in picking +
                          file.') SECLVL('Cause . . . . . :   The +
                          batch number you entered was not found in +
                          the picking file. &N Recovery  . . . :   +
                          Enter a batch number that has already +
                          been picked.') SEV(30)
             ENDDO

/*  OR35021 Batch number not found in summary file. */

             CHGVAR     VAR(&MSGID) VALUE('OR35021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch does not exist in summary +
                          file.') SECLVL('Cause . . . . . :   The +
                          batch number you entered was not found in +
                          the summary file. &N Recovery  . . . :   +
                          Batch summary records are created when +
                          labels are printed.  Either reprint the +
                          labels for the batch or enter a batch +
                          number for a set of labels that have +
                          already been printed.') SEV(30)
             ENDDO

/*  OR50019 No open orders found for warehouse. */

             CHGVAR     VAR(&MSGID) VALUE('OR50019')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          open orders found for warehouse.') +
                          SECLVL('Cause . . . . . :   No open +
                          orders were found for warehouse &1. &N +
                          Recovery  . . . :   Enter a different +
                          warehouse and try again.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO

/*  OR50020 No open orders found for route. */

             CHGVAR     VAR(&MSGID) VALUE('OR50020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          open orders found for route.') +
                          SECLVL('Cause . . . . . :   No open +
                          orders were found for route &2 in +
                          warehouse &1. &N Recovery  . . . :   +
                          Enter a different route or *ALL to select +
                          all routes for the warehouse.') SEV(30) +
                          FMT((*DEC 3) (*CHAR 5))
             ENDDO

/*  OR50021 Allocating stock from slots. */

             CHGVAR     VAR(&MSGID) VALUE('OR50021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Allocating stock from slots.') SEV(00)
             ENDDO

/*  OR50022 Building pallets.*/

             CHGVAR     VAR(&MSGID) VALUE('OR50022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Building pallets.') SEV(00)
             ENDDO

/*  OR50023 Picking stock from slots. */

             CHGVAR     VAR(&MSGID) VALUE('OR50023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Picking stock from slots.') SEV(00)
             ENDDO

/*  OR50024 Printing labels. */

             CHGVAR     VAR(&MSGID) VALUE('OR50024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Printing labels.') SEV(00)
             ENDDO

/*  OR50025 Printing loading sheet. */

             CHGVAR     VAR(&MSGID) VALUE('OR50025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Printing loading sheet.') SEV(00)
             ENDDO

/*  OR50026 Printing pallet summary. */

             CHGVAR     VAR(&MSGID) VALUE('OR50026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Printing pallet summary.') SEV(00)
             ENDDO

/*  OR51021 No new orders exist to be picked. */

             CHGVAR     VAR(&MSGID) VALUE('OR51021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          new orders on file.') SECLVL('Cause . . . +
                          . . :   There were no new orders found in +
                          the customer order file. &N Recovery  . . +
                          . :   Receive customer orders and try +
                          again.') SEV(30)
             ENDDO

/*  OR54521 No records exist for warehouse/batch/route. */

             CHGVAR     VAR(&MSGID) VALUE('OR54521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          records exist for warehouse/batch/route +
                          combination.') SECLVL('''Cause . . . . . +
                          :   No label records were found for +
                          warehouse &1, batch &2 and route &3. &N +
                          Recovery  . . . :   Enter a different +
                          warehouse/batch/route combination and try +
                          again.') SEV(30) FMT((*DEC 3) (*DEC 7) +
                          (*CHAR 5))
             ENDDO

/*  OR54522 Batch is not a customer picking batch. */

             CHGVAR     VAR(&MSGID) VALUE('OR54522')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch &1 is not a customer picking +
                          batch.') SECLVL('Cause . . . . . :   +
                          Batch &1 is type &2 instead of *PICK. &N +
                          Recovery  . . . :   Enter a customer +
                          picking batch number.') SEV(30) FMT((*DEC +
                          7) (*CHAR 8))
             ENDDO

/*  OR54523 Batch is not a transfer picking batch. */

             CHGVAR     VAR(&MSGID) VALUE('OR54523')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Batch &1 is not a transfer picking +
                          batch.') SECLVL('Cause . . . . . :   +
                          Batch &1 is type &2 instead of *TFRPICK. +
                          &N Recovery  . . . :   Enter a customer +
                          picking batch number.') SEV(30) FMT((*DEC +
                          7) (*CHAR 8))
             ENDDO

             RETURN
             ENDPGM
