/*------------------------------------------------------------------*/
/*  English Version (Spanish version is TFMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  TFMSGD      Create PIRMSGF Message Descriptions TFpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  01 March, 1996                                                  */
/*  Hemant Kapadia                                                  */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  TF12201 Cannot edit this transfer order. */

             CHGVAR     VAR(&MSGID) VALUE('TF12201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot edit this transfer order.') +
                          SECLVL('Cause . . . . . :   Transfer +
                          order number &1 is &2. Therefore, it +
                          cannot be edited. &N Recovery  . . . :   +
                          Enter an open order number and try your +
                          request again.') SEV(30) FMT((*DEC 7) +
                          (*CHAR 20))
             ENDDO

/*  TF12202 Picking and requesting warehouse cannot be the same. */

             CHGVAR     VAR(&MSGID) VALUE('TF12202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Picking and requesting warehouse +
                          cannot be the same.') SECLVL('Cause . . . +
                          . . :   Picking warehouse number entered +
                          is the same as the requesting warehouse. +
                          &N Recovery  . . . :   Enter a warehouse +
                          number that is different from the +
                          requesting warehouse number, and try your +
                          request again.') SEV(30)
             ENDDO

/*  TF12203 Qty ordered is > Qty available. Cannot authorize.    */

             CHGVAR     VAR(&MSGID) VALUE('TF12203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot authorize transfer of item +
                          &4.') SECLVL('Cause . . . . . :   +
                          Quantity ordered for item &4 is &2 which +
                          is more than the quantity available &3. +
                          &N Recovery  . . . :   Press F12 to +
                          cancel, and then change the quantity +
                          ordered, so that it is less than or equal +
                          to the quantity available in warehouse +
                          &1, and then try your request again.') +
                          SEV(30) FMT((*DEC 3 0) (*DEC 7 0) (*DEC 7 +
                          0) (*CHAR 15))
             ENDDO

/*  TF13201 Item does not exist.             */

             CHGVAR     VAR(&MSGID) VALUE('TF13201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          does not exist.') SECLVL('Cause . . . . . +
                          :   Item does not exist in warehouse &1. +
                          &N Recovery  . . . :   Enter an item that +
                          exists in both the picking and requesting +
                          warehouse.') SEV(30) FMT((*DEC 3))
             ENDDO

/*  TF13202 Qty being transferred is > Qty available.  */

             CHGVAR     VAR(&MSGID) VALUE('TF13202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity ordered &2 is more than +
                          available &3.') SECLVL('Cause . . . . . +
                          :   Quantity ordered &2 is more than +
                          quantity available &3 from warehouse &1. +
                          &N Recovery  . . . :   Enter a quantity +
                          that is less than or equal to available +
                          quantity.') SEV(30) FMT((*DEC 3) (*DEC 7 +
                          0) (*DEC 7 0))
             ENDDO

/*  TF16001 Transfer number does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('TF16001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transfer number &1 does not exist.') +
                          SECLVL('Cause . . . . . :   Transfer +
                          order number &1 was not found. &N +
                          Recovery  . . . :   Enter a different +
                          transfer order number and try your +
                          request again.') SEV(30) FMT((*DEC 7))
             ENDDO

/*  TF17201 Warning: Qty received not equal to Qty ordered. */

             CHGVAR     VAR(&MSGID) VALUE('TF17201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Quantity received is not +
                          equal to the quantity ordered.') +
                          SECLVL('Cause . . . . . :   The quantity +
                          received is either more than or less than +
                          the quantity ordered. &N Recovery  . . . +
                          :   Press F20 to accept the warning and +
                          receive the entered quantity or press F12 +
                          to cancel.') SEV(10)
             ENDDO

/*  TF17202 Info. message.                                  */

             CHGVAR     VAR(&MSGID) VALUE('TF17202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 received and may be combined with +
                          order &2 for shipment.') SECLVL('No +
                          further information.') SEV(0) FMT((*CHAR +
                          15) (*DEC 7 0))
             ENDDO

/*  TF50020 Copying authorized orders to picking files. */

             CHGVAR     VAR(&MSGID) VALUE('TF50020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Copying authorized orders to picking +
                          files.') SEV(00)
             ENDDO

             RETURN
             ENDPGM
