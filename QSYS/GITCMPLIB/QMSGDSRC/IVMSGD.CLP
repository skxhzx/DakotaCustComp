/*------------------------------------------------------------------*/
/*  English Version (Spanish version is IVMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  IVMSGD      Create PIRMSGF Message Descriptions IVpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  30 January 1996                                                 */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  4-26-99  V4.11  RH                                              */
/*    ADDED IV33001 AND IV33002                                     */
/*  5-06-99  V4.11  RH                                              */
/*    ADDED IV50027 AND IV50028 AND IV35421                         */
/*                                                                  */
/*  09/29/99 V4.12  DAS                                             */
/*    ADDED IV21302, IV21303 and IV21304                            */
/*                                                                  */
/*  03/03/00 V4.13  DAS                                             */
/*    ADDED IV50003, IV50004, IV50005                               */
/*  08/30/00 V4.14  RRH                                             */
/*    ADDED IV21202                                                 */
/*  1-27-03  V4.16  RH                                              */
/*    ADDED IV50029                                                 */
/*  6-13-06  V5.00  RH                                              */
/*    ADDED IV21305                                                 */
/*  7-19-06  V5.10a RH                                              */
/*    ADDED IV26401 and IV26402                                     */
/*  09/01/06 5.10b  RH                                              */
/*    ADDED IV21306                                                 */
/*  09/06/06 5.10c  RH                                              */
/*    ADDED IV21203                                                 */
/*  09/07/06 5.10d  RH                                              */
/*    ADDED IV21307                                                 */
/*  11/07/06 5.10e  RH                                              */
/*    ADDED IV21204                                                 */
/*  12/18/06 5.10f  RH                                              */
/*    ADDED IV33004                                                 */
/*  06/08/07 5.10g  RH                                              */
/*    ADDED IV33005                                                 */
/*  05/08/08 5.20a  RH                                              */
/*    ADDED IV27201                                                 */
/*  05/12/08 5.20b  RH                                              */
/*    ADDED IV33006                                                 */
/*  02/09/12 6.40A  LMC                                             */
/*    ADDED IV33007                                                 */
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

/*  IV11005 Slots are being selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slots are being selected.  Please be +
                          patient.')
             ENDDO

/*  IV11006 Verifying slots haven't been selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Verifying that slots have not +
                          already been selected.')
             ENDDO

/*  IV11007 Verifying slots can be unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Verifying that slots can be +
                          unselected.')
             ENDDO

/*  IV11008 Unselectin slots. */

             CHGVAR     VAR(&MSGID) VALUE('IV11008')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unselecting slots. Please be patient.')
             ENDDO

/*  IV11021 No records selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          slots were selected. Position cursor on +
                          this line and press F1.') SECLVL('Cause . +
                          . . . . :   No slots matched the entered +
                          criteria. &N Recovery  . . . :   Enter +
                          new criteria and try again.') SEV(30)
             ENDDO

/*  IV11022 Records were selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots were selected.') SECLVL('Cause . . +
                          . . . :   &1 slots were selected based on +
                          the scope entered. &N Recovery  . . . :   +
                          Enter a different scope to select more +
                          slots or press F3 to return to the +
                          menu.') SEV(00) FMT((*DEC 7 0))
             ENDDO

/*  IV11023 Unmonitored error occured. */

             CHGVAR     VAR(&MSGID) VALUE('IV11023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unmonitored error occured (&1).') +
                          SECLVL('Cause . . . . . :   The SQL +
                          selection did not complete because of +
                          error code &1. &N Recovery  . . . :   +
                          Report this to the D.P. manager.') +
                          SEV(30) FMT((*DEC 5 0))
             ENDDO

/*  IV11024 Slots already exist for scope. */

             CHGVAR     VAR(&MSGID) VALUE('IV11024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          slots selected. &1 were previously +
                          selected.') SECLVL('Cause . . . . . :   +
                          &1 slots were found in the inventory work +
                          file that fall within the entered scope. +
                          Therefore, no new slots were selected. &N +
                          Recovery  . . . :   Clear the inventory +
                          work file and try the select again or +
                          enter a different scope.') SEV(30) +
                          FMT((*DEC 7 0))
             ENDDO

/*  IV11025 Slots can not be unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slots can not be unselected. Page +
                          numbers have already been generated.') +
                          SECLVL('Cause . . . . . :   Page numbers +
                          have already been generated for the slots +
                          you are trying to unselect. &N Recovery  +
                          . . . :   Pages must be entered, the +
                          inventory closed and the process started +
                          again.') SEV(30)
             ENDDO

/*  IV11026 Slots were unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots were unselected.') SECLVL('Cause . +
                          . . . . :   &1 slots were unselected +
                          based on the scope entered. &N Recovery  +
                          . . . :   None.') SEV(00) FMT((*DEC 7 0))
             ENDDO

/*  IV11027 No slots unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          slots were unselected. Position cursor +
                          on this line and press F1.') +
                          SECLVL('Cause . . . . . :   No slots +
                          matched the entered criteria. &N +
                          Recovery  . . . :   Enter new criteria +
                          and try again.') SEV(30)
             ENDDO

/*  IV12521 sheets printed. */

             CHGVAR     VAR(&MSGID) VALUE('IV12521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          inventory sheets were printed.') SEV(0) +
                          FMT((*DEC 5 0))
             ENDDO

/*  IV21201 Qty entered without item number. */

             CHGVAR     VAR(&MSGID) VALUE('IV21201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity entered without item +
                          number.') SECLVL('Cause . . . . . :   +
                          Quantity was entered but no item number +
                          was entered. &N Recovery  . . . :   Enter +
                          item number and try again.') SEV(30)
             ENDDO

/*  IV21202 Cannot change item, pending qty exists. */

             CHGVAR     VAR(&MSGID) VALUE('IV21202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot change item, pending qty +
                          exists.') SECLVL('Cause . . . . . :   +
                          Quantity exists other than stock +
                          quantity. &N Recovery  . . . :   Physically +
                          remove item from slot.') SEV(30)
             ENDDO

/*  IV21203 Cannot count item, pending qty exists. */

             CHGVAR     VAR(&MSGID) VALUE('IV21203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot count item, pending qty +
                          exists.') SECLVL('Cause . . . . . :   +
                          Quantity exists other than stock +
                          quantity. &N Recovery  . . . :   Physically +
                          remove item from slot.') SEV(30)
             ENDDO

/*  IV21204 Must enter slot postion not 0. */

             CHGVAR     VAR(&MSGID) VALUE('IV21204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Must enter slot position greater +
                          than 0.') SECLVL('Cause . . . . . :   +
                          Multiple position slot. +
                          &N Recovery  . . . :   Enter position +
                          greater than 0.') SEV(30)
             ENDDO

/*  IV21301 Item exists in physical location. */

             CHGVAR     VAR(&MSGID) VALUE('IV21301')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Item exists in physical location +
                          .') SECLVL('Cause . . . . . :   +
                          This item exists in the physical slot or +
                          virtual slot. &N Recovery  . . . :   Enter +
                          different slot and try again.') SEV(30)
             ENDDO

/*  IV21302 Slot is not a physical slot */

             CHGVAR     VAR(&MSGID) VALUE('IV21302')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          &1 is not a physical slot.') +
                          SECLVL('Cause . . . . . :   Slot &1 is a +
                          virtual slot. A virtual slot can only be +
                          created for a physical slot.  &N +
                          Recovery  . . . :   Enter a physical slot +
                          and try your request again.') SEV(30) +
                          FMT((*CHAR 12))
             ENDDO

/*  IV21303 Virtual slot not allowed for physical slot */

             CHGVAR     VAR(&MSGID) VALUE('IV21303')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Virtual slots are not allowed for +
                          slots with two character handstack.') +
                          SECLVL('Cause . . . . . :   The physical +
                          slot, &1, has a two character handstack +
                          code. A virutal slot uses one position of +
                          the handstack code to make it a unique +
                          slot within the system. Therefore, any +
                          slot which uses both positions of the +
                          handstack code can not have a +
                          corresponding virual slot.  &N Recovery  +
                          . . . :   Select a slot that does not +
                          have a handstack code or only uses one +
                          position of the code and try your request +
                          again.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IV21304 Virtual slot could not be created. */

             CHGVAR     VAR(&MSGID) VALUE('IV21304')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Virtual slot could not be created +
                          for &1.') SECLVL('Cause . . . . . :   A +
                          Virtual slot could not be created for +
                          physical slot &1. Either the physical +
                          slot already has the maximum virtual +
                          slots attached to it or the physical slot +
                          is a handstack slot which uses both +
                          positions of the handstack field.  &N +
                          Recovery  . . . :   Zero verify any +
                          virtual slots for the physical slot or +
                          select a different slot to transfer the +
                          item to. Then, try your request again.') +
                          SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IV21305 Not Catch weight item. */

             CHGVAR     VAR(&MSGID) VALUE('IV21305')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Not catch weight +
                          item.') SECLVL('Cause . . . . . :   +
                          Item is not defined as catch weight. +
                          &N Recovery  . . . :   Change item +
                          or do not enter weight.') SEV(30)
             ENDDO

/*  IV21306 Item department different than slot. */

             CHGVAR     VAR(&MSGID) VALUE('IV21306')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Item dept different than slot +
                          dept.') SECLVL('Cause . . . . . :   +
                          Item department is different than slot +
                          department. &N Recovery  . . . :   Enter +
                          different item and try again.') SEV(30)
             ENDDO


/*  IV21307 UCI already entered in inventory. */

             CHGVAR     VAR(&MSGID) VALUE('IV21307')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('UCI already entered in +
                          inventory.') SECLVL('Cause . . . . . :   +
                          UCI already entered in inventory. +
                          &N Recovery  . . . :   Scan another +
                          UCI and try again.') SEV(30)
             ENDDO


/*  IV26401 Inventory Page assigned. */

             CHGVAR     VAR(&MSGID) VALUE('IV26401')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          assigned.') SECLVL('No further +
                          information for this message.') SEV(00) +
                          FMT((*CHAR 50))
             ENDDO


/*  IV26402 Inventory Page Unassigned. */

             CHGVAR     VAR(&MSGID) VALUE('IV26402')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          UnAssigned.') SECLVL('No further +
                          information for this message.') SEV(00) +
                          FMT((*CHAR 50))
             ENDDO

/*  IV27201 Can not assign, sheets not printed. */

             CHGVAR     VAR(&MSGID) VALUE('IV27201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unable to assign, sheets not +
                          printed.') SECLVL('Cause . . . . . :   +
                          Unable to assign, sheets not printed for dept.+
                          &N Recovery  . . . :   Print sheets, +
                          then retry to assign.') SEV(30)
             ENDDO

/*  IV33001 No team defined for date. */

             CHGVAR     VAR(&MSGID) VALUE('IV33001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No team defined for +
                          date.') SECLVL('Cause . . . . . :   +
                          No team is defined with entered date. +
                          &N Recovery  . . . :   Define team +
                          or correct and try again.') SEV(30)
             ENDDO


/*  IV33002 Slot not in inventory scope. */

             CHGVAR     VAR(&MSGID) VALUE('IV33002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot not in inventory +
                          scope.') SECLVL('Cause . . . . . :   +
                          Slot is not defined in inventory scope. +
                          &N Recovery  . . . :   Scan correct +
                          slot and try again.') SEV(30)
             ENDDO

/*  IV33003 Slot already entered in inventory. */

             CHGVAR     VAR(&MSGID) VALUE('IV33003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot already entered in +
                          inventory.') SECLVL('Cause . . . . . :   +
                          Slot already entered in inventory. +
                          &N Recovery  . . . :   Scan another +
                          slot and try again.') SEV(30)
             ENDDO

/*  IV33004 Option not set for Add.   */

             CHGVAR     VAR(&MSGID) VALUE('IV33004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot add item to +
                          slot.') SECLVL('Cause . . . . . :   +
                          Option not set to allow add item to slot. +
                          &N Recovery  . . . :   Mark exception +
                          or tell supervisor.') SEV(30)
             ENDDO

/*  IV33005 # of Pick slots exceeds allowed.   */

             CHGVAR     VAR(&MSGID) VALUE('IV33005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Put in (&1) # of pick slots +
                          > allowed..') +
                          SECLVL('Cause . . . . . :   +
                          After add, number of pick slots would be +
                          greater than number of allowed +
                          &N Recovery  . . . :   Put in pick +
                          slot or aisle.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IV33006 Quantity entered without item confirmed.       */

             CHGVAR     VAR(&MSGID) VALUE('IV33006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity entered without item +
                          confirmed') SECLVL('Cause . . . :   +
                          Quantity was entered, no item confirmation +
                          was entered. &N Recovery  . . . :   Enter +
                          confirmation value and try again.') SEV(30)
             ENDDO

/*  IV33007 COunt print sheet option has not been run.     */

             CHGVAR     VAR(&MSGID) VALUE('IV33007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Print Sheet Option must be run') +
                                      SECLVL('Cause . . . :   +
                          Inventory Control must print sheets before +
                          entry      . &N Recovery  . . . :   Print +
                          Sheets and try again.') SEV(30)
             ENDDO

/*  IV35421 Inventory Exception cleared. */

             CHGVAR     VAR(&MSGID) VALUE('IV35421')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          cleared.') SECLVL('No further +
                          information for this message.') SEV(00) +
                          FMT((*CHAR 50))
             ENDDO


/*  IV50003 Crete FTP expor file */ /* 413 A */

             CHGVAR     VAR(&MSGID) VALUE('IV50003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Create FTP expor file.') SEV(00)
             ENDDO

/*  IV50004 Move records to history files */ /* 413 A */

             CHGVAR     VAR(&MSGID) VALUE('IV50004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Move +
                          records to history files.') SEV(00)
             ENDDO

/*  IV50005 Export counts via FTP */ /* 413 A */

             CHGVAR     VAR(&MSGID) VALUE('IV50005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Export counts via FTP.') SEV(00)
             ENDDO

/*  IV50021 Updating slot quantities and item numbers */

             CHGVAR     VAR(&MSGID) VALUE('IV50021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Updating slot quantities and item +
                          numbers.') SEV(00)
             ENDDO

/*  IV50022 Updating slot status codes */

             CHGVAR     VAR(&MSGID) VALUE('IV50022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Updating slot status codes.') SEV(00)
             ENDDO

/*  IV50023 Uping slot breakdown quantities */

             CHGVAR     VAR(&MSGID) VALUE('IV50023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Uping slot breakdown quantities.') +
                          SEV(00)
             ENDDO

/*  IV50024 Recalculating warehouse qtys from slot qtys */

             CHGVAR     VAR(&MSGID) VALUE('IV50024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Recalculating warehouse quantities +
                          from slot quantities.') SEV(00)
             ENDDO

/*  IV50025 Uping warehouse breakdown quantites */

             CHGVAR     VAR(&MSGID) VALUE('IV50025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Uping warehouse breakdown +
                          quantities.') SEV(00)
             ENDDO

/*  IV50026 Can not post, some sheets not entered.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unable to post, some sheets not +
                          entered.') SECLVL('Cause . . . . . :   +
                          Unable to post, some sheets not entered.+
                          &N Recovery  . . . :   Use F9 to view +
                          status of inventory.') SEV(30)
             ENDDO

/*  IV50027 Can not post, some slots not entered.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unable to post, some slots not +
                          entered.') SECLVL('Cause . . . . . :   +
                          Unable to post, some slots not entered.+
                          &N Recovery  . . . :   Use F9 to view +
                          status of inventory.') SEV(30)
             ENDDO

/*  IV50028 Can not post, inventory exceptions exust.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50028')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unable to post, inventory exceptions +
                          exist.') SECLVL('Cause . . . . . :   +
                          Unable to post, some exceptions exist.+
                          &N Recovery  . . . :   Use F9 to view +
                          status of inventory.') SEV(30)
             ENDDO

/*  IV50029 Can not post, Error slots exist.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50029')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unable to post, inventory slots have +
                          errors.') SECLVL('Cause . . . . . :   +
                          Unable to post, some slot errors exist.+
                          &N Recovery  . . . :   Use F9 to view +
                          status of inventory.') SEV(30)
             ENDDO

/*  IV51021 Updating slots for warehouse/dept/section. */

             CHGVAR     VAR(&MSGID) VALUE('IV51021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Updating Slots for Warehouse &1, +
                          Department &2, Section &3.') SEV(00) +
                          FMT((*DEC 3) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  IV52021 Updating warehouse counts for warehouse/dept. */

             CHGVAR     VAR(&MSGID) VALUE('IV52021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Updating Warehouse Counts for +
                          Warehouse &1, Department &2.') SEV(00) +
                          FMT((*DEC 3) (*CHAR 5))
             ENDDO

/*  INV7978  Next page record is locked. */

             CHGVAR     VAR(&MSGID) VALUE('INV7978')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Next +
                          sheet number record is locked by another +
                          user.') SECLVL('Cause . . . . . :   The +
                          next sheet number record in file INVNXTP +
                          is being used by another user. &N +
                          Recovery  . . . :   Wait until the record +
                          is not being used and try again.') SEV(30)
             ENDDO

             RETURN
             ENDPGM
