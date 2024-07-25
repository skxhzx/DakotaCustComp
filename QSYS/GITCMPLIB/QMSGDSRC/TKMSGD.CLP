/*------------------------------------------------------------------*/
/*  English Version (Spanish version is TKMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  TKMSGD      Create PIRMSGF Message Descriptions TKpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  11 June 1997                                                    */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  09/29/00  DAS 4.14  Revised message PS14203                     */
/*  12/17/02  DAS 4.16  Added message PS14204                       */
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



/*  TM13201 Unload seq # already exists for compartment      */

             CHGVAR     VAR(&MSGID) VALUE('TM13201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Duplicate unload sequence exists for +
                          compartment.') SECLVL('Cause . . . . . +
                          :   The unload sequence already exists +
                          for this compartment. &N Recovery  . . . :   +
                          Change the unload sequence number and try +
                          your request again.') SEV(30)
             ENDDO
/*  PS14201 New cube on pallet will be greater than max cube. */

             CHGVAR     VAR(&MSGID) VALUE('PS14201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Warning: +
                          New cube will be greater than max cube, Press +
                          F20 to accept warning.') +
                          SECLVL('Cause . . . . . :   The new cube +
                          of (&1) created by the move is greater +
                          than the max cube of (&2) for the pallet. +
                          &N Recovery  . . . :   F20 to accept the warning or +
                          F12 to not move the product.') SEV(30) FMT((*DEC +
                          7 3) (*DEC 5 2))
             ENDDO

/*  PS14202 Move To and from row/col cannot be the same. */

             CHGVAR     VAR(&MSGID) VALUE('PS14202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot  move product to same +
                          pallet.') SECLVL('Cause . . . . . :   The +
                          move from row/col is the same as the move +
                          to row/col. &N Recovery  . . . :   Change +
                          the move to row and column and try your +
                          request again.') SEV(30)
             ENDDO

/*  PS14203 Total bulk picks on pallet greater than max. (9) */

             CHGVAR     VAR(&MSGID) VALUE('PS14203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot move product. Bulk picks on +
                          destination pallet would exceed max of +
                          9.') SECLVL('Cause . . . . . :   The stop +
                          being moved contains one or more bulk +
                          picks. The destination pallet also +
                          contains one or more bulk picks. When +
                          combined the total bulk picks on the +
                          destination pallet would be greater than +
                          the maximum allowed of 9. &N Recovery  . +
                          . . :   Change the destination row and +
                          column and try your request again.') SEV(30)
             ENDDO

/*  PS14204 Zone mismatch - Cannot mix items from different zones. */

             CHGVAR     VAR(&MSGID) VALUE('PS14204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Zone +
                          mismatch - Cannot mix items from +
                          different zones (&1/&2).') SECLVL('Cause +
                          . . . . . :   Trying to move items from a +
                          pallet for zone &1 to a pallet for zone +
                          &2. This is not allowed when the "To" +
                          pallet already has items on it. &N +
                          Recovery  . . . :   Move items to a +
                          different pallet, or remove all items +
                          from the "To" pallet and try your request +
                          again.') SEV(30) FMT((*CHAR 6) (*CHAR 6))
             ENDDO

/*  RH12001 Invalid truck number.  */

             CHGVAR     VAR(&MSGID) VALUE('RH12001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid truck number.') +
                          SECLVL('Cause . . . . . :   The truck +
                          number is invalid. &N Recovery  . . . :   +
                          Change the truck number and try your +
                          request again.') SEV(30)
             ENDDO

/*  TK12221 Parent zone can not be same as above zone. */

             CHGVAR     VAR(&MSGID) VALUE('TK12221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Parent zone can not be the same as +
                          above zone.') SECLVL('Cause . . . . . :   +
                          The parent zone entered is the same as +
                          the zone being edited. &N Recovery  . . . +
                          :   Enter a different zone and try your +
                          request again.') SEV(30)
             ENDDO

/*  TK12222 Zone must be entered when compartment is blank. */

             CHGVAR     VAR(&MSGID) VALUE('TK12222')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Parent zone must be entered when +
                          compartment is blank.') SECLVL('Cause . . +
                          . . . :   A code was not entered for the +
                          Parent Zone and the compartment is blank. +
                          Zones that do not create pallets to be +
                          put into a truck compartment must +
                          identify the zone the product should be +
                          merged into (Parent Zone).  &N Recovery  +
                          . . . :   Enter a valid zone into the +
                          Parent Zone and try your request again.') +
                          SEV(30)
             ENDDO

/*  TK12223 Zone can not be entered when compartment is not blank. */

             CHGVAR     VAR(&MSGID) VALUE('TK12223')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Parent zone can not be entered when +
                          compartment is not blank.') SECLVL('Cause +
                          . . . . . :   A code was entered for the +
                          Parent Zone and the Compartment is not +
                          blank. Zones that create pallets to be +
                          put into a truck compartment can not be +
                          merged into another zone (Parent Zone).  +
                          &N Recovery  . . . :   Either change the +
                          Compartment value or the Parent Zone to +
                          blank and try your request again.') SEV(30)
             ENDDO

/*  ZH13221 Aisle does not exist in department. */

             CHGVAR     VAR(&MSGID) VALUE('ZH13221')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aisle &1 does not exist in +
                          department &2.') SECLVL('Cause . . . . . +
                          :   Aisle &1 does not exist in department +
                          &2. &N Recovery  . . . :   Enter an aisle +
                          that does exist in department &2 or leave +
                          blank.') SEV(30) FMT((*CHAR 3) (*CHAR 5))
             ENDDO

/*  ZH13222 Section must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('ZH13222')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Section must be entered when Aisle, +
                          Level or Locations are entered.') +
                          SECLVL('Cause . . . . . :   A value was +
                          entered for the Aisle, Level and/or +
                          Location without entering a value for +
                          Section. &N Recovery  . . . :   Either +
                          enter a value for Section or remove the +
                          values entered for Aisle, Level and/or +
                          Location.') SEV(30)
             ENDDO

/*  ZH13223 Aisle must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('ZH13223')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aisle must be entered when Level or +
                          Locations are entered.') SECLVL('Cause . +
                          . . . . :   A value was entered for the +
                          Level and/or Location without entering a +
                          value for Aisle. &N Recovery  . . . :   +
                          Either enter a value for Aisle or remove +
                          the values entered for Level and/or +
                          Location.') SEV(30)
             ENDDO

             RETURN
             ENDPGM
