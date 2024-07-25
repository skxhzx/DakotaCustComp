/*------------------------------------------------------------------*/
/*  English Version (Spanish version is OPMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  OPMSGD      Create PIRMSGF Message Descriptions OPpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  18 June 1993                                                    */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  Revisions                                                       */
/*                                                                  */
/*    03/03/99  DAS  4.11                                           */
/*      - Added message OP16021.                                    */
/*                                                                  */
/*    09/26/01  DAS  4.16                                           */
/*      - Added message OP13521.                                    */
/*                                                                  */
/*    10/06/01  DAS  4.16a                                          */
/*      - Revised message OP13521 to allow option 1 & 2.            */
/*    05/22/07  RH   5.10a                                          */
/*      - Enh: Add message OP3501                                   */
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

/*  OP11021 Rows of labels can not exceed 6. */

             CHGVAR     VAR(&MSGID) VALUE('OP11021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Rows +
                          of labels can not exceed 6.') +
                          SECLVL('Cause . . . . . :   A number +
                          greater than 6 was enterd for the rows of +
                          labels per page. &N Recovery  . . . :   +
                          Enter a number from 1 to 6.') SEV(30)
             ENDDO

/*  OP11022 Aisle does not exist in PIR section. */

             CHGVAR     VAR(&MSGID) VALUE('OP11022')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aisle &1 does not exist in the PIR +
                          section of the &2 department.') +
                          SECLVL('Cause . . . . . :   Aisle &1 does +
                          not exist in the PIR section of the &2 +
                          department. &N Recovery  . . . :   Enter +
                          an aisle that does exist in the PIR +
                          section of department &2 or leave +
                          blank.') SEV(30) FMT((*CHAR 3) (*CHAR 5))
             ENDDO

/*  OP13021 Program name can not be blank. */

             CHGVAR     VAR(&MSGID) VALUE('OP13021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          value entered for program name.') +
                          SECLVL('Cause . . . . . :   A program +
                          name was not entered. This field is +
                          manditory. &N Recovery  . . . :   Enter a +
                          program name to continue.') SEV(30)
             ENDDO

/*  OP13022 Error occured during test call to program. */

             CHGVAR     VAR(&MSGID) VALUE('OP13022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          is not a valid receiving label program.') +
                          SECLVL('Cause . . . . . :   An error +
                          occured during a test call to program &1. +
                          Either the program does not exist or the +
                          parameter list is incorrect. &N Recovery  +
                          . . . :   Make sure the receiving label +
                          program you want to use already exists +
                          and uses the correct parameter list.') +
                          SEV(30) FMT((*CHAR 10))
             ENDDO

/*  OP13023 Duplicate priority entered. */

             CHGVAR     VAR(&MSGID) VALUE('OP13023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Priority &1 has already been +
                          defined.') SECLVL('Cause . . . . . :   A +
                          priority number can only be used once and +
                          priority &1 has already been entered for +
                          a previous option. &N Recovery  . . . :   +
                          Enter a unique priority number for each +
                          option.') SEV(30) FMT((*DEC 1 0))
             ENDDO

/*  OP13024 Aisle priority must be greater than Side prioirty. */

             CHGVAR     VAR(&MSGID) VALUE('OP13024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Side +
                          priority must be greater than the Aisle +
                          priority.') SECLVL('Cause . . . . . :   +
                          The side priority (&1) is less than the +
                          aisle priority (&2). &N Recovery  . . . +
                          :   Change the side priority so it is +
                          greater than the aisle priority.') +
                          SEV(30) FMT((*DEC 1 0) (*DEC 1))
             ENDDO

/*  OP13521 Value must be 'Total' when only entering on 1st receipt */

             CHGVAR     VAR(&MSGID) VALUE('OP13521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value must be 1 or 2 when entering +
                          on first receipt') SECLVL('Cause . . . . +
                          . :   Option "&1" was entered for the +
                          Catch Weight Value to Enter, but the +
                          Allow Catch Weight Entry is set to +
                          2=First Receipt Only. When the catch +
                          weight is being enterd on the first +
                          receipt only, the Catch Weight Value must +
                          be set to 1=Choice or 2=Total. &N +
                          Recovery  . . . :   Either change Catch +
                          Weight Value to 1=Choice or 2=Total, or +
                          change Allow Catch Weight Entry from +
                          2=First Receipt Only to something else.') +
                          SEV(30) FMT((*CHAR 1))
             ENDDO

/*  OP16021 Password fields do not match. */

             CHGVAR     VAR(&MSGID) VALUE('OP16021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Password fields do not match.') +
                          SECLVL('Cause . . . . . :   The value +
                          entered in the Password field does not +
                          match the value entered in the Password +
                          Verification field. &N Recovery  . . . +
                          :   Re-enter the values.  Remember, the +
                          case of each character must be the same +
                          in each value.') SEV(30)
             ENDDO

/*  OP03501  Add item must be 'Y' for scan UPC/LIC or key in item. */

             CHGVAR     VAR(&MSGID) VALUE('OP03501')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Add +
                          item must be Y.') +
                          SECLVL('Cause . . . . . :   +
                          The Add item option must be Y if scan UPC/ +
                          Lic or key item is Y. &N Recovery  . . . +
                          :   Change add item in slot option to +
                          Y.') +
                          SEV(30) FMT((*DEC 1 0) (*DEC 1))
             ENDDO


             RETURN
             ENDPGM
