/*------------------------------------------------------------------*/
/*  English Version (Spanish version is EQMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  EQMSGD      Create PIRMSGF Message Descriptions EQpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Equipment check in/out error messages               */
/*                                                                  */
/*  27 March 2003                                                   */
/*  Roxanne Harrison                                                */
/*  03/27/03  RH  4.17  Add EQ82001 message.                        */
/*  07/16/03  RH  4.17a Add EQ52001 & EQ52002 messages.             */
/*  02/16/04  MLB 4.17b Add EQ52003 & EQ52004 messages.             */
/*  02/18/04  RH  4.17c Add EQ52005                                 */
/*  09/12/05  RH  5.00b Add EQ41001 message                         */
/*  09/12/05  RH  5.00b Add EQ41002 message                         */
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

/*  EQ41001 Invalid entry, must be 'Y'.                        */

             CHGVAR     VAR(&MSGID) VALUE('EQ41001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Must enter Y.') +
                          SECLVL('''Cause . . . . . :   Can not +
                          enter N, must enter Y. &N Recovery           +
                          . . . :   Enter Y for answer.''') SEV(30)
             ENDDO

/*  EQ41002 Field 1 must be greater than or equal to field 2. */

             CHGVAR     VAR(&MSGID) VALUE('EQ41002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be greater than or equal to &2.') +
                          SECLVL('Cause . . . . . :   The value you +
                          entered for &1 (&3) must be greater than +
                          or equal to the existing value for &2 +
                          (&4). &N Recovery  . . . :   Enter a +
                          value that is greater than &2.') SEV(30) +
                          FMT((*CHAR 15) (*CHAR 15) (*DEC 7) (*DEC 7))
             ENDDO

/*  EQ52001 Repair already completed.                           */

             CHGVAR     VAR(&MSGID) VALUE('EQ52001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot repair, completed.') +
                          SECLVL('''Cause . . . . . :   Can not +
                          enter repair, already completed. &N Recovery +
                          . . . :   Check work order # is correct, +
                          change option.''') SEV(30)
             ENDDO

/*  EQ52002 Cannot repair, work order not printed.              */

             CHGVAR     VAR(&MSGID) VALUE('EQ52002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot repair, print work order.') +
                          SECLVL('''Cause . . . . . :   Can not +
                          enter repair, work order not printed. &N +
                          Recovery . . . :   Print work order # +
                          then retry option.''') SEV(30)
             ENDDO

/*  EQ52003 Equipment type must be: TRACTR, TRAILR, TRUCKS.     */

             CHGVAR     VAR(&MSGID) VALUE('EQ52003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Equipment type must be: TRACTR, +
                          TRAILR, TRUCKS.') SECLVL('Cause . . . . . +
                          :   You have entered a equipment type +
                          that is not allowed for Yard Management +
                          tracking. &N Recovery . . . :   Enter in +
                          one of the following equipment types: +
                          TRACTR, TRAILR, TRUCKS and try your +
                          request again.') SEV(30)
             ENDDO

/*  EQ52004 Equipment status must be: I,D,L,O,N.                     */

             CHGVAR     VAR(&MSGID) VALUE('EQ52004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Equipment status must be: I,D,L,O,N +
                          .') SECLVL('Cause . . . . . :   You have +
                          entered a equipment status that is not +
                          allowed for Yard Management tracking. &N +
                          Recovery . . . :   Enter in one of the +
                          following valid statuses: I=In Yard, +
                          D=Dock, L=Loaded, O=Out, N=Out of Service +
                          and try your request again.') SEV(30)
             ENDDO

/*  EQ52005 Use original work order to repair                   */

             CHGVAR     VAR(&MSGID) VALUE('EQ52005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot repair, use orig work order.') +
                          SECLVL('''Cause . . . . . :   Can not +
                          enter repair, use original work order. &N Recove+
                          . . . :   Check work order # is correct, +
                          change option.''') SEV(30)
             ENDDO


/*  EQ82001 No Equipment checked out.                           */

             CHGVAR     VAR(&MSGID) VALUE('EQ82001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No Equipment checked out.') +
                          SECLVL('''Cause . . . . . :   User has +
                          not checked out equipment. &N Recovery . . +
                          . :   Check out equipment then retry +
                          option.''') SEV(30)
             ENDDO


             RETURN
             ENDPGM
