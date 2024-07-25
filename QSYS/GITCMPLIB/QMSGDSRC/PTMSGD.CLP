/*------------------------------------------------------------------*/
/*  English Version (Spanish version is PTMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  PTMSGD      Create PIRMSGF Message Descriptions PTpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  17 October 1994                                                 */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  Revisions                                                       */
/*                                                                  */
/*    04/04/95  DAS  2.10                                           */
/*      - Added message PT13018.                                    */
/*    10/01/98  RH   4.10                                           */
/*      - Added message PT13019.                                    */
/*    08/04/99  RH   4.12                                           */
/*      - Added message PT13020.                                    */
/*    12/14/99  MLB  4.13                                           */
/*      - Added message PT13031.                                    */
/*    02/23/00  MLB  4.13a                                          */
/*      - Added message PT13032. Note: This message is identical    */
/*        to PT13031, just formatted to 40 characters.              */
/*    07/20/01  HNK  4.15                                           */
/*      - Added message PT13033.                                    */
/*    10/19/01  MLB  4.16                                           */
/*      - Added message PT14001.                                    */
/*    09/10/03  RH   4.17                                           */
/*      - Added message PT13035.                                    */
/*    12/04/03  RH   4.17a                                          */
/*     -  Add PT64001 & PT64002 message.                            */
/*    02/28/04  HNK  4.17b                                          */
/*     -  Add PT64003 message.                                      */
/*    03/16/04  DAS  5.00                                           */
/*     -  Add PT64004 message.                                      */
/*    12/30/04  RH   5.00b                                          */
/*     -  Add PT64005 message.                                      */
/*    06/24/05  MLB  5.00c                                          */
/*     -  Add PT13021 message. This message is nearly identical     */
/*        to PT13019, but wording changed to reflect error on       */
/*        weight entered.                                           */
/*    12/19/05  RH   5.00d                                          */
/*     -  Add PT64006 message.                                      */
/*    10/30/07  HNK  5.10a                                          */
/*     -  Add PT13022 message.                                      */
/*    11/08/07  RBD  5.10                                           */
/*     -  Add PT13201 message.                                      */
/*    09/11/08  HNK  5.20a                                          */
/*     -  Add PT13036 message.                                      */
/*    08/28/13  RBD  6.50a                                          */
/*     -  Added PT13023 message ... shortened version of PT13019.   */
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

/*  PT13010 Transaction can not be closed. Slot not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13010')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Slot +
                          &1 not found.') SECLVL('Cause . . . . . +
                          :   Slot &1 does not exist. &N Recovery  +
                          . . . :   Slot must be created before you +
                          can close this transaction.') SEV(30) +
                          FMT((*CHAR 12))
             ENDDO

/*  PT13011 Transaction can not be closed. Item not in slot. */

             CHGVAR     VAR(&MSGID) VALUE('PT13011')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Slot +
                          &1 does not contain item &2.') +
                          SECLVL('Cause . . . . .     Slot &1 does +
                          not contain item &2 anymore. &N Recovery  +
                          . . . :   You must update the slot with +
                          the item before you can close this +
                          transaction.') SEV(30) FMT((*CHAR 12) +
                          (*CHAR 15))
             ENDDO

/*  PT13012 Transaction can not be closed. Transaction not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13012')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. +
                          Transaction &1 not found.') SECLVL('Cause +
                          . . . . . :   Transaction &1 does not +
                          exist. &N Recovery  . . . :   Transaction +
                          record must be created before you can +
                          close this transaction.') SEV(30) +
                          FMT((*DEC 7 0))
             ENDDO

/*  PT13013 Transaction can not be closed. Order detail not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13013')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Order +
                          detail not found for item &1.') +
                          SECLVL('Cause . . . . . :   Order detail +
                          for item &1 does not exist. &N Recovery  +
                          . . . :   Order detail for item must be +
                          created before you can close this +
                          transaction.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PT13014 Transaction can not be closed. Label not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13014')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Label +
                          &1 not found.') SECLVL('Cause . . . . . +
                          :   Label &1 does not exist. &N Recovery  +
                          . . . :   Label record must be created +
                          before you can close this transaction.') +
                          SEV(30) FMT((*DEC 7 0))
             ENDDO

/*  PT13015 Transaction not completed. Receiving slot not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13015')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction could not be completed. +
                          Receiving slot &1 not found.') +
                          SECLVL('Cause . . . . . :   The +
                          transaction you are closing includes a +
                          transfer request. However, the receiving +
                          slot (&1) does not exist. &N Recovery  . +
                          . . :   Everything has been updated +
                          properly except the slot to receive the +
                          transfer.  You will have to make a manual +
                          adjustment to the slot that was supposed +
                          to receive the item.') SEV(30) FMT((*CHAR +
                          12))
             ENDDO

/*  PT13016 Tran not be completed. Item not in receiving slot. */

             CHGVAR     VAR(&MSGID) VALUE('PT13016')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction could not be completed. +
                          Receiving slot &1 does not contain item +
                          &2.') SECLVL('Cause . . . . . :   The +
                          transaction you are closing includes a +
                          transfer request. However, the receiving +
                          slot (&1) does not contain item &2. &N +
                          Recovery  . . . :   Everything has been +
                          updated properly except the slot to +
                          receive the transfer.  You will have to +
                          make a manual adjustment to the slot that +
                          was supposed to receive the item.') +
                          SEV(30) FMT((*CHAR 12) (*CHAR 15))
             ENDDO

/*  PT13017 Transaction can not be closed. P.O. detail not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13017')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. P.O. +
                          detail not found for item &1.') +
                          SECLVL('Cause . . . . . :   P.O. detail +
                          for item &1 does not exist. &N Recovery  +
                          . . . :   P.O. detail for item must be +
                          created before you can close this +
                          transaction.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PT13018 Transaction can not be closed. Not enough quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PT13018')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Not +
                          enough stock in slot.') SECLVL('Cause . . +
                          . . . :   Slot &1 does not contain enough +
                          stock for the extra quantity entered +
                          (&2). &N Recovery  . . . :   An inventory +
                          adjustment must be made to slot &1 before +
                          this transaction can be closed.') SEV(30) +
                          FMT((*CHAR 12) (*DEC 7))
             ENDDO

/*  PT13019 Warning: Total catch weight is not with +/- range. */

             CHGVAR     VAR(&MSGID) VALUE('PT13019')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Total catch weight of &1 is +
                          not within -/+ range of &2 / &3.') +
                          SECLVL('Cause . . . . . :   The total catch +
                          weight entered (&1) is not within the +
                          variance range of not less than &4 % or +
                          greater than &5 % of the expected weight of +
                          (&6). &N Recovery  . . . :   You may press +
                          F20 to accept the warning with no change, +
                          or change the catch weights entered.') +
                          SEV(00) +
                          FMT((*DEC 9 2) (*DEC 9 2) (*DEC 9 2) +
                          (*DEC 3 1) (*DEC 3 1) (*DEC 9 2))
             ENDDO

/*  PT13020 Total # of catch weights entered not equal to qty picked.*/

             CHGVAR     VAR(&MSGID) VALUE('PT13020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('# of catch weights entered &1 is +
                          not equal to quantity picked of &2') +
                          SECLVL('Cause . . . . . :   The total number+
                           of catch weights entered (&1) is not  +
                          equal to the quantity picked of &2). +
                          &N Recovery  . . . :   You need to +
                          enter as many catch weights as quantiy +
                          picked.') +
                          SEV(00) +
                          FMT((*DEC 5 0) (*DEC 5 0))
             ENDDO

/*  PT13021 Warning: Entered weight is not with +/- range. */

             CHGVAR     VAR(&MSGID) VALUE('PT13021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Entered wgt &1 is +
                          not within -/+ range of &2 / &3.') +
                          SECLVL('Cause . . . . . :   The entered +
                          weight (&1) is not within the +
                          variance range of not less than &4 % or +
                          greater than &5 % of the expected weight of +
                          (&6). &N Recovery  . . . :   You may press +
                          F20 to accept the warning with no change, +
                          or change the catch weight value entered.') +
                          SEV(00) +
                          FMT((*DEC 9 2) (*DEC 9 2) (*DEC 9 2) +
                          (*DEC 3 1) (*DEC 3 1) (*DEC 9 2))
             ENDDO

/*  PT13022 Transaction can not be closed. UCI don't match qty */

             CHGVAR     VAR(&MSGID) VALUE('PT13022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Label +
                          &1 - Verify UCIs entered.') SECLVL('Cause +
                          . . . . . :   Number of UCIs entered for +
                          Label &1 does not match picked quantity. +
                          &N Recovery  . . . :   Take option to +
                          enter UCIs for Label &1 and then try your +
                          request again.') SEV(30) FMT((*DEC 7 0))
             ENDDO

/*  PT13023 Warning: Tot c/w is not within +/- range.  650aA */

             CHGVAR     VAR(&MSGID) VALUE('PT13023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Tot c/w &1 is +
                          not within -/+ range of &2 / &3.') +
                          SECLVL('Cause . . . . . :   The total catch +
                          weight entered (&1) is not within the +
                          variance range of not less than &4 % or +
                          greater than &5 % of the expected weight of +
                          (&6). &N Recovery  . . . :   You may press +
                          F20 to accept the warning with no change, +
                          or change the catch weights entered.') +
                          SEV(00) +
                          FMT((*DEC 9 2) (*DEC 9 2) (*DEC 9 2) +
                          (*DEC 3 1) (*DEC 3 1) (*DEC 9 2))
             ENDDO

/*  PT13030 Transaction closed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PT13030')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction &1 closed +
                          successfully.') SECLVL('No further +
                          detail.') SEV(00) FMT((*DEC 7))
             ENDDO

/*  PT13031 Transaction can not be closed. Not enough quantity -
            replenished to slot. */

             CHGVAR     VAR(&MSGID) VALUE('PT13031')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Not +
                          enough quantity replenished to slot.') +
                          SECLVL('Cause . . . . . :   Not enough +
                          quantity is being replenished into the +
                          slot to cover the quantity being picked +
                          and/or transfered from slot &1 leaving a +
                          negative available quantity. &N Recovery  +
                          . . . :   Change the replenishment +
                          quantity to a amount greater than or +
                          equal to (&2) and try your request +
                          again.') SEV(30) FMT((*CHAR 12) (*DEC 7))
             ENDDO

/*  PT13032 Transaction can not be closed. Not enough quantity -
            replenished to slot. */

             CHGVAR     VAR(&MSGID) VALUE('PT13032')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Tran. not closed. Short replenish +
                          qty.') +
                          SECLVL('Cause . . . . . :   Not enough +
                          quantity &B is being replenished into the +
                          slot to &B cover the quantity being picked +
                          and/ &B or transfered from slot &1 &B leaving a +
                          negative available quantity. &N Recovery  +
                          . . . :   Change the &B replenishment +
                          quantity to a amount &B greater than or +
                          equal to (&2) &B and try your request +
                          again.') SEV(30) FMT((*CHAR 12) (*DEC 7))
             ENDDO

/*  PT13033 Transaction can not be closed. Manual Putaway.      */

             CHGVAR     VAR(&MSGID) VALUE('PT13033')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. +
                          Manual Putaway.') SECLVL('Cause . . . . . +
                          :   Transaction is manual putaway +
                          transaction and hence cannot be closed +
                          here. &N Recovery  . . . :   Use putaway +
                          program and scan/enter the slot the +
                          product was putaway to close this +
                          transaction') SEV(30) FMT((*CHAR 12) +
                          (*DEC 7))
             ENDDO

/*  PT13035 Transaction already closed.                         */

             CHGVAR     VAR(&MSGID) VALUE('PT13035')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction already closed.') +
                          SECLVL('Cause . . . . . +
                          :   Transaction is already closed +
                          can not enter catch weights. +
                          Recovery  . . . :   Catch weight +
                          were entered before transaction was +
                          closed') SEV(30) FMT((*CHAR 12) +
                          (*DEC 7))
             ENDDO

/*  PT13036 Transaction can not be closed. Qty > Label qty      */

             CHGVAR     VAR(&MSGID) VALUE('PT13036')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. +
                          Quantity greater than label quantity.') +
                          SECLVL('Cause . . . . . :   Replenish +
                          quantity is greater than quantity +
                          generated for transaction. &N Recovery  . +
                          . . :   Change the quantity to less than +
                          or equal to the label quantity and try +
                          your request again.') SEV(30) FMT((*CHAR +
                          12) (*DEC 7))
             ENDDO

/*  PT14001 Customer Return has been exported. Qty change not allowed. */

             CHGVAR     VAR(&MSGID) VALUE('PT14001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Customer Return has been exported. +
                          Quantity change not allowed.') +
                          SECLVL('Cause . . . . . :   Customer +
                          Return has been exported and the system +
                          value does not allow changes to return +
                          quantity if return record has been +
                          exported back to host system. &N +
                          Recovery  . . . :   Change return +
                          quantity back to original value and press +
                          Enter to close this transaction. Then +
                          perform an inventory adjustment to the +
                          slot the product was returned.') SEV(30) +
                          FMT(*NONE)
             ENDDO

/*  PT64001 Multiple transaction, end using task entry. */

             CHGVAR     VAR(&MSGID) VALUE('PT64001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Multiple trans, use task entry to end.') +
                          SECLVL('Cause . . . . . :   The transaction +
                          is a multiple trans. Use task entry to +
                          end before closing. &N Recovery  . +
                          . . :   End transaction before +
                          closing.') SEV(30) FMT(*NONE)
             ENDDO

/*  PT64002 Multiple transaction, can't use F16 close all. */

             CHGVAR     VAR(&MSGID) VALUE('PT64002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Multiple trans exists, can not close all.') +
                          SECLVL('Cause . . . . . :   Multiple transactions +
                          exist.  Cannot use F16 to close all. Use task +
                          entry to end before closing. &N Recovery  . +
                          . . :   Use another option to +
                          close.') SEV(30) FMT(*NONE)
             ENDDO

/*  PT64003 Flag pending, cannot close transaction.     */

             CHGVAR     VAR(&MSGID) VALUE('PT64003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Flag +
                          pending, Remove before closing.') +
                          SECLVL('Cause . . . . . :   There is +
                          atleast one flag pending for this +
                          transaction.  &N Recovery  . . . :   +
                          Either change the quantity of the flagged +
                          item or place the cursor on the flagged +
                          item and press F7 to remove the flag.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PT64004  Not authorized to close transaction.     */

             CHGVAR     VAR(&MSGID) VALUE('PT64004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('User +
                          &1 not authorized to close transaction') +
                          SECLVL('Cause . . . . . :   Only certain +
                          users are allowed to close transactions +
                          for MEAT-INSP, PRE-PICK and CONTAINER +
                          routes. &N Recovery  . . . :   Sign on +
                          with an authorized user id and try +
                          again.') SEV(30) FMT((*CHAR 10))
             ENDDO

/*  PT64005 Trans started, cannot close transaction.     */

             CHGVAR     VAR(&MSGID) VALUE('PT64005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Trans +
                          started, can not close.') +
                          SECLVL('Cause . . . . . :   Transaction +
                          is started, can not close. +
                            &N Recovery  . . . :   +
                          Use task entry to end the transaction  +
                          or ask the user to end transaction.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PT64006 WORKSOS rec, can not close transaction.    5.00d  */

             CHGVAR     VAR(&MSGID) VALUE('PT64006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          WORKSOS records pending, Can not close.') +
                          SECLVL('Cause . . . . . :   There is +
                          at least one SOS item being worked on for +
                          this transaction.  &N Recovery  . . . :   +
                          Either wait for the using to finish the +
                          SOS or contact management to remove +
                          the record.') +
                          SEV(30) FMT(*NONE)
             ENDDO


/*  PT75010 Transactions/Labels deleted successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PT75010')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          tranasactions and &2 labels were +
                          removed.') SEV(00) FMT((*DEC 5 0) (*DEC 5 0))
             ENDDO

/*  PT13201 Transaction can not be closed. Item not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaction can not be closed. Item +
                          &1 not found.') SECLVL('Cause . . . . . +
                          :   Item &1 does not exist. &N Recovery  +
                          . . . :   Item record must be created +
                          before you can close this transaction.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

             RETURN
             ENDPGM
