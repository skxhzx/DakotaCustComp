/*------------------------------------------------------------------*/
/*  English Version (Spanish version is PIRMSGDSP)                  */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/********************************************************************/
/*                                                                  */
/*  PIRMSGF     Create PIRMSGF Message Descriptions PIRnnnn         */
/*              Standard messages for PIR                          */
/*  14 February 1991                                                */
/*  Dave Sommerville                                                */
/*  12/20/98  RH  4.10  Add PIR2101 message.                       */
/*  10/05/99  MLB 4.13  Add PIR1021 message.                       */
/*  12/08/99  MLB 4.13  Add PIR0123 message.                        */
/*  12/28/99  MLB 4.13  Add PIR0124 message.                        */
/*  04/12/00  MLB 4.14  Add PIR9907 message.                        */
/*  07/06/00  MLB 4.14  Add PIR1051 message.                        */
/*  04/18/01  DAS 4.15  Add PIR7983 message.                        */
/*  07/31/01  MLB 4.16  Add PIR1052 message.                        */
/*  04/25/02  MLB 4.16  Add PIR1053 message.                        */
/*  04/26/02  MLB 4.16  Add PIR1054 message.                        */
/*  04/28/02  MLB 4.16  Add PIR1055 message.                        */
/*  04/28/02  MLB 4.16  Add PIR1056 message.                        */
/*  07/25/02  MLB 4.16  Add PIR9908 message.                        */
/*  11/26/02  MLB 4.16  Add PIR1057 message.                        */
/*  11/26/02  MLB 4.16  Add PIR1058 message.                        */
/*  11/26/02  MLB 4.16  Add PIR1059 message.                        */
/*  12/04/02  MLB 4.16  Add PIR2007 message.                        */
/*  01/16/03  RH  4.17  Add PIR4001 message.                        */
/*  10/14/03  RH  4.17b Add PIR4001 message.                        */
/*  02/11/04  RH  4.17c Add PIR9909 message.                        */
/*  08/19/04  MLB 4.17d Add PIR1060 message.                        */
/*                      Add PIR1061 message.                        */
/*  11/17/04  RH  5.00a Add PIR0206 message.                        */
/*  11/28/05  JJ  5.00b Add PIR1011 message.                        */
/*  12/21/05  JJ  5.00c Add PIR1012 message.                        */
/*  12/23/05  JJ  5.00d Add PIR1013 message.                        */
/*  01/02/06  JJ  5.00e Add PIR1014 message.                        */
/*  02/23/06  JJ  5.00f Add PIR1015 message.                        */
/*  03/10/06  JJ  5.00g Add PIR1016 message.                        */
/*  04/03/06  JJ  5.00h Add PIR1017 message.                        */
/*                      Add PIR1018 message.                        */
/*  04/12/06  JJ  5.00i Add PIR1019 message.                        */
/*  04/19/06  DAS 5.00j Add PIR1062 message.                        */
/*                      Add PIR1063 message.                        */
/*                      Add PIR1064 message.                        */
/*  05/05/06  JJ  5.00k Add PIR1020 message.                        */
/*                      Add PIR1022 message.                        */
/*                      Add PIR1023 message.                        */
/*  07/10/06  MLB 5.10  Add PIR0751 message.                        */
/*  09/11/06  RAH 5.10  Add PIR9910 message.                        */
/*  09/11/06  RAH 5.10  Add PIR9911 message.                        */
/*                      Add PIR9912 message.                        */
/*  09/27/06  RAH 5.10  Add PIR9999 generic message.                */
/*  10/19/06  MLB 5.10  Add msg's PIR0125 - PIR0138.                */
/*  01/27/07  MLB 5.10a Add msg's PIR0141 - PIR0142.                */
/*  03/21/07  TJ  5.10B Add msg's PIR0143.                          */
/*  08/10/07  JCJ 5.10c Add msg's PIR0144.                          */
/*  08/10/07  JCJ 5.10c Add msg's PIR0145.                          */
/*  09/05/07  JCJ 5.10d Add msg's PIR0146.                          */
/*  09/07/07  LMC 5.10e Add msg's PIR0147.                          */
/*  09/21/07  DAS 5.10f Add msg's PIR0148.                          */
/*  12/28/07  JCJ 5.10G Add msg's PIR0149 - PIR0152                 */
/*  01/25/10  GJA 5.30a Add msg's PIR0752                           */
/*  02/08/12  JCJ 6.40A Add msg PIR9913                             */
/*  04/27/12  RH  6.40B Add msg PIR0153                             */
/*  03/28/12  LMC 6.40d Add msg PIR2102                             */
/*  04/11/12  LMC 6.40c Add msg PIR2103                             */
/*  09/23/16  TAB 7.00a Add msg's PIR2104 - PIR2106                 */
/*  01/09/18  MLB 7.10  Add msg PIR1393                             */
/*                                                                  */
/********************************************************************/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  PIR0001 Option under construction */

             CHGVAR     VAR(&MSGID) VALUE('PIR0001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          option you selected is being enhanced and +
                          is not available.') SECLVL('Cause . . . . +
                          . :   The option you selected is being +
                          enhanced and is not available at this +
                          time. &N Recovery  . . . :   Contact your +
                          DP manager for instructions.') SEV(0) +
                          FMT((*CHAR 6))
             ENDDO

/*  PIR0101 Program not found */

             CHGVAR     VAR(&MSGID) VALUE('PIR0101')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Program &1 not found for option +
                          &2.') SECLVL('Cause . . . . . :   Option +
                          &2 calls program &1 which was not found. +
                          &N Recovery  . . . :   Contact your DP +
                          manager for instructions.') SEV(30) +
                          FMT((*CHAR 10) (*CHAR 6))
             ENDDO

/*  PIR0102 Program not found.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0102')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Program &1 not found for F&2.') +
                          SECLVL('Cause . . . . . :   F&2 calls +
                          program &1 which was not found. &N +
                          Recovery  . . . :   Contact your DP +
                          manager for instructions.') SEV(30) +
                          FMT((*CHAR 10) (*CHAR 6))
             ENDDO

/*  PIR0103 Program not found. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0103')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Program &1 not found while executing +
                          subroutine &2.') SECLVL('Cause . . . . . +
                          :   Subroutine &2 calls program &1 which +
                          was not found. &N Recovery  . . . :   +
                          Contact your DP manager for +
                          instructions.') SEV(30) FMT((*CHAR 10) +
                          (*CHAR 6))
             ENDDO

/*  PIR0104 Invalid key pressed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0104')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('You +
                          have pressed an invalid key.') +
                          SECLVL('Cause . . . . . :   The function +
                          key you pressed is not valid for display +
                          you are using. &N Recovery  . . . :   +
                          Examine the bottom of the display for the +
                          valid function keys for this display.') +
                          SEV(30)
             ENDDO

/*  PIR0105 No more help. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0105')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('&1') SECLVL('Cause . . . . . :   +
                          There is no more help for this message.') +
                          SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR0106 Invalid cursor position. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0106')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid cursor position for "Move to +
                          Top"') SECLVL('Cause . . . . . :   Cursor +
                          not on displayed record. &N Recovery  . . +
                          . :   Move cursor t the record you want +
                          positioned at the top of the display and +
                          try the operation again.') SEV(30)
             ENDDO

/*  PIR0107 Invalid value for "Position to". */

             CHGVAR     VAR(&MSGID) VALUE('PIR0107')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid value entered for "Position +
                          to".') SECLVL('Cause . . . . . :   Value +
                          entered for "Position to" is not valid. +
                          &N Recovery  . . . :   Enter a valid +
                          value.') SEV(30)
             ENDDO

/*  PIR0108 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0108')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option &1 is not valid.') +
                          SECLVL('Cause . . . . . :   The option +
                          you entered  is not valid for display you +
                          are using. &N Recovery  . . . :   Examine +
                          the top of the display for the valid +
                          options for this display.') SEV(30) +
                          FMT((*CHAR 2))
             ENDDO

/*  PIR0109 Number can not be less than zero. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0109')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          can not be less than zero.') +
                          SECLVL('Cause . . . . . :   The value you +
                          entered for &1 is negative. &N Recovery  +
                          . . . :   Enter a value that is greater +
                          than or equal to zero.') SEV(30) +
                          FMT((*CHAR 40))
             ENDDO

/*  PIR0110 Number must be greater than zero. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0110')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be greater than zero.') +
                          SECLVL('Cause . . . . . :   The value you +
                          entered for &1 is zero or negative. &N +
                          Recovery  . . . :   Enter a value that is +
                          greater than zero.') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0111 Error occured when calling receiving label program. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0111')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error occured trying to call &1 +
                          program &2.') SECLVL('Cause . . . . . :   +
                          An error occured while calling &1 program +
                          &2. &N Recovery  . . . :   Contact the +
                          data processing manager.') SEV(30) +
                          FMT((*CHAR 30) (*CHAR 10))
             ENDDO

/*  PIR0112 Valid range for field is ... */

             CHGVAR     VAR(&MSGID) VALUE('PIR0112')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Valid range for &1 is &2 to &3.') +
                          SECLVL('Cause . . . . . :   The value you +
                          entered for &1 is not in the range of &2 +
                          to &3. &N Recovery  . . . :   Enter a +
                          value that is in the range of &2 to &3.') +
                          SEV(30) FMT((*CHAR 30) (*CHAR 10) (*CHAR 10))
             ENDDO

/*  PIR0113 Field 1 must be greater than or equal to field 2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0113')

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
                          or equal to the value entered for &2 +
                          (&4). &N Recovery  . . . :   Enter a +
                          value that is greater than &2.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*DEC 3) (*DEC 3))
             ENDDO

/*  PIR0114 Invalid character used in quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0114')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid character (''&1'') used in +
                          quantity.') SECLVL('Cause . . . . . :   +
                          The character ''&1'' in position &2 is +
                          invalid for quantity. &N Recovery  . . . +
                          :   Valid characters for quantities are 0 +
                          through 9, ''.'' and ''-'' if negatives +
                          are allowed.') SEV(30) FMT((*CHAR 1) +
                          (*DEC 3))
             ENDDO

/*  PIR0115 Too many decimal points entered in quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0115')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Too +
                          many decimal points entered in +
                          quantity.') SECLVL('Cause . . . . . :   +
                          More than two decimal points were entered +
                          in quantity. &N Recovery  . . . :   +
                          Re-enter quantity with a maximum of two +
                          decimal points.') SEV(30)
             ENDDO

/*  PIR0116 Quantity is too large. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0116')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid quantity entered.') +
                          SECLVL('Cause . . . . . :   One of the +
                          individual quantities entered is greater +
                          than 9,999,999. &N Recovery  . . . :   +
                          Make sure each quantity entered is not +
                          greater than 9,999,999.') SEV(30)
             ENDDO

/*  PIR0117 Quantity could not be allocated in full. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0117')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity could not be allocated in +
                          full.') SECLVL('''Cause . . . . . :   The +
                          quantity to be allocated (&1) was greater +
                          than the quantity available (&2). &N +
                          Recovery  . . . :   The actual quantity +
                          that was allocated is &3.  If this is not +
                          satisfactory you will need to make +
                          adjustments to increase the quantity +
                          available.') SEV(30) FMT((*CHAR 10) +
                          (*CHAR 10) (*CHAR 10))
             ENDDO

/*  PIR0118 Quantity could not be allocated in full. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0117')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity could not be allocated in +
                          full.') SECLVL('''Cause . . . . . :   The +
                          quantity to be allocated (&1) was greater +
                          than the quantity available (&2). &N +
                          Recovery  . . . :   The actual quantity +
                          that was allocated is &3.  If this is not +
                          satisfactory you will need to make +
                          adjustments to increase the quantity +
                          available.') SEV(30) FMT((*CHAR 10) +
                          (*CHAR 10) (*CHAR 10))
             ENDDO

/*  PIR0119 Field 1 must be greater than or equal to field 2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0119')

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
                          or equal to the value entered for &2 +
                          (&4). &N Recovery  . . . :   Enter a +
                          value that is greater than &2.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*DEC 9) (*DEC 9))
             ENDDO

/*  PIR0120 Value entered without option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0120')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value entered without option.') +
                          SECLVL('Cause . . . . . :   You have +
                          entered a value without entering an +
                          option to operate on that value. &N +
                          Recovery  . . . :   Either enter a valid +
                          option or blank out the value.') SEV(30)
             ENDDO

/*  PIR0122 Invalid value entered for aisle. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0122')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid value entered for aisle.') +
                          SECLVL('Cause . . . . . :   Aisle &1 does +
                          not exist. &N Recovery  . . . :   Enter a +
                          valid aisle name and try your request +
                          again.') SEV(30) FMT((*CHAR 4))
             ENDDO

/*  PIR0123 Replenishment quantity is not a multiple of pick quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0123')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Replenishment quantity (&1) is not a +
                          multiple of pick quantity (&2).') +
                          SECLVL('Cause . . . . . :   The +
                          replenishment quantity (&1) is not a +
                          multiple of the picking quantity (&2). +
                          There are (&3 &4) in each full unit +
                          picked. &N Recovery  . . . :   Enter a +
                          replenishment quantity that is a multiple +
                          of (&5) picked multiplied by (&3 &4) in +
                          each full unit. If less than a full unit +
                          was picked you will have to perform a +
                          slot adjustment after the transaction has +
                          been closed to correct the quantity in +
                          the slot.') SEV(30) FMT((*DEC 5) (*DEC 5) +
                          (*DEC 5) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  PIR0124 Day abbreviation not valid.                                */

             CHGVAR     VAR(&MSGID) VALUE('PIR0124')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Day +
                          (&1) to Compute Averages is not a valid +
                          abbreviation.') SECLVL('Cause . . . . . +
                          :   The day abbreviation entered (&1) is +
                          not valid. &N Recovery  . . . :   Enter +
                          one of the following for a valid +
                          abbreviation: SUN, MON, TUE, WED, THU, +
                          FRI or SAT.  Then try your request +
                          again.') SEV(30) FMT((*CHAR 3))
             ENDDO

/*  PIR0125 *Warning* Item File not found. Item Update not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0125')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Item file: &1 not found. +
                          Import Item Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the Item +
                          file with the import data is missing. &N +
                          Recovery . . . : Verify Host processes +
                          are properly creating data file. File +
                          name from semaphore file must match +
                          Import Item file name minus S prefix. +
                          Re-run Host process to create Import Item +
                          Update file and check messages after file +
                          has been created. Use cmd WRKLNK to +
                          verify files exist in correct +
                          directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0126 *Warning* P/O Hdr file not found. P/O Update not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0126')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* P/O Hdr file: &1 not +
                          found. Import P/O Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the P/O +
                          Hdr file with the import data is missing. +
                          &N Recovery . . . : Verify Host processes +
                          are properly creating data file. File +
                          name from semaphore file must match +
                          Import P/O Hdr file name minus S prefix. +
                          Re-run Host process to create Import +
                          Purchase Order Updates file and check +
                          messages after file has been created. Use +
                          cmd WRKLNK to verify files exist in +
                          correct directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0127 *Warning* P/O Dtl file not found. P/O Update not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0127')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* P/O Dtl file: &1 not +
                          found. Import P/O Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the P/O +
                          Detail file with the import data is +
                          missing. &N Recovery . . . : Verify Host +
                          processes are properly creating data +
                          file. File name from semaphore file must +
                          match Import P/O Detail file name minus S +
                          prefix. Re-run Host process to create +
                          Import Purchase Order Updates file and +
                          check messages after file has been +
                          created. Use cmd WRKLNK to verify files +
                          exist in correct directory.') SEV(30) +
                          FMT((*CHAR 128))
             ENDDO

/*  PIR0128 *Warning* Customer Order Hdr not found. Cust. Ord not processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0128')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Customer Ord Hdr file: &1 +
                          not found. Import Customer Orders not +
                          processed.') SECLVL('Cause . . . . . :   +
                          The semaphore file was found for file: &1 +
                          but the Customer Order Hdr file with the +
                          import data is missing. &N Recovery . . . +
                          : Verify Host processes are properly +
                          creating data file. File name from +
                          semaphore file must match Import Customer +
                          Order Hdr file name minus S prefix. +
                          Re-run Host process to create Import +
                          Customer Orders file and check messages +
                          after file has been created. Use cmd +
                          WRKLNK to verify files exist in correct +
                          directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0129 *Warning* Customer Order Dtl not found. Cust. Ord not processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0129')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Customer Ord Dtl file: &1 +
                          not found. Import Customer Orders not +
                          processed.') SECLVL('Cause . . . . . :   +
                          The semaphore file was found for file: &1 +
                          but the Customer Order Detail file with the +
                          import data is missing. &N Recovery . . . +
                          : Verify Host processes are properly +
                          creating data file. File name from +
                          semaphore file must match Import Customer +
                          Order Detail file name minus S prefix. +
                          Re-run Host process to create Import +
                          Customer Orders file and check messages +
                          after file has been created. Use cmd +
                          WRKLNK to verify files exist in correct +
                          directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0130 *Warning* Item Misc File not found. Item Update not processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0130')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Item Misc file: &1 not +
                          found. Import Item Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the Item +
                          file with the import data is missing. &N +
                          Recovery . . . : Verify Host processes +
                          are properly creating data file. File +
                          name from semaphore file must match +
                          Import Item file name minus S prefix. +
                          Re-run Host process to create Import Item +
                          Update file and check messages after file +
                          has been created. Use cmd WRKLNK to +
                          verify files exist in correct +
                          directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0131 P/O Hdr Misc file not found. P/O Update not Processed.           */

             CHGVAR     VAR(&MSGID) VALUE('PIR0131')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* P/O Hdr Misc file: &1 not +
                          found. Import P/O Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the P/O +
                          Hdr Misc file with the import data is +
                          missing. &N Recovery . . . : Verify Host +
                          processes are properly creating data +
                          file. File name from semaphore file must +
                          match Import P/O Hdr Misc file name minus +
                          S prefix. Re-run Host process to create +
                          Import Purchase Order Updates file and +
                          check messages after file has been +
                          created. Use cmd WRKLNK to verify files +
                          exist in correct directory.') SEV(30) +
                          FMT((*CHAR 128))
             ENDDO

/*  PIR0132 P/O Dtl Misc file not found. P/O Update not Processed.           */

             CHGVAR     VAR(&MSGID) VALUE('PIR0132')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* P/O Dtl Misc file: &1 not +
                          found. Import P/O Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the P/O +
                          Detail Misc file with the import data is +
                          missing. &N Recovery . . . : Verify Host +
                          processes are properly creating data +
                          file. File name from semaphore file must +
                          match Import P/O Detail Misc file name +
                          minus S prefix. Re-run Host process to +
                          create Import Purchase Order Updates file +
                          and check messages after file has been +
                          created. Use cmd WRKLNK to verify files +
                          exist in correct directory.') SEV(30) +
                          FMT((*CHAR 128))
             ENDDO

/*  PIR0133 Cust Order Hdr Misc file not found. Customer Orders not process. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0133')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Cust. Order Hdr Misc file: +
                          &1 not found. Import Cust. Orders not +
                          processed.') SECLVL('Cause . . . . . :   +
                          The semaphore file was found for file: &1 +
                          but the Customer Order Hdr Misc file with +
                          the import data is missing. &N Recovery . +
                          . . : Verify Host processes are properly +
                          creating data file. File name from +
                          semaphore file must match Import Customer +
                          Order Hdr Misc file name minus S prefix. +
                          Re-run Host process to create Import +
                          Customer Orders file and check messages +
                          after file has been created. Use cmd +
                          WRKLNK to verify files exist in correct +
                          directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0134 Cust Order Dtl Misc file not found. Customer Orders not process. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0134')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Cust. Order Dtl Misc file: +
                          &1 not found. Import Cust. Orders not +
                          processed.') SECLVL('Cause . . . . . :   +
                          The semaphore file was found for file: &1 +
                          but the Customer Order Detail Misc file +
                          with the import data is missing. &N +
                          Recovery . . . : Verify Host processes +
                          are properly creating data file. File +
                          name from semaphore file must match +
                          Import Customer Order Detail Misc file +
                          name minus S prefix. Re-run Host process +
                          to create Import Customer Orders file and +
                          check messages after file has been +
                          created. Use cmd WRKLNK to verify files +
                          exist in correct directory.') SEV(30) +
                          FMT((*CHAR 128))
             ENDDO

/*  PIR0135 Error copying files. Import Item Update not processed.           */

             CHGVAR     VAR(&MSGID) VALUE('PIR0135')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copying files for: &1. Import +
                          Item Update not processed.') +
                          SECLVL('Cause . . . . . :   An error +
                          occured while copying files from import +
                          directory to import data files. &N +
                          Recovery . . . : Check for previous +
                          messages in message queues IMPITEM and +
                          IMPITEMERR for additional details. +
                          Semaphore file renamed to Err_&1. +
                          Semaphore file and import data file not +
                          deleted from directory. Semaphore file +
                          and import data file will need to be +
                          deleted manually. Use cmd WRKLNK to +
                          delete files. Correct errors and then try +
                          your request again.') SEV(30) FMT((*CHAR +
                          128))
             ENDDO

/*  PIR0136 Error copying files. Import P/O Update not processed.            */

             CHGVAR     VAR(&MSGID) VALUE('PIR0136')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copying files for: &1. Import +
                          P/O Update not processed.') SECLVL('Cause +
                          . . . . . :   An error occured while +
                          copying files from import directory to +
                          import data files. &N Recovery . . . : +
                          Check for previous messages in message +
                          queues IMPPO and IMPPOERR for additional +
                          details. Semaphore file renamed to +
                          Err_&1. Semaphore file and import data +
                          file not deleted from directory. +
                          Semaphore file and import data file will +
                          need to be deleted manually. Use cmd +
                          WRKLNK to delete files. Correct errors +
                          and then try your request again.') +
                          SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0137 Error copying files. Import Customer Orders not processed.        */

             CHGVAR     VAR(&MSGID) VALUE('PIR0137')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copying files for: &1. Import +
                          Customer Orders not processed.') +
                          SECLVL('Cause . . . . . :   An error +
                          occured while copying files from import +
                          directory to import data files. &N +
                          Recovery . . . : Check for previous +
                          messages in message queues IMPORD and +
                          IMPORDERR for additional details. +
                          Semaphore file renamed to Err_&1. +
                          Semaphore file and import data file not +
                          deleted from directory. Semaphore file +
                          and import data file will need to be +
                          deleted manually. Use cmd WRKLNK to +
                          delete files. Correct errors and then try +
                          your request again.') SEV(30) FMT((*CHAR +
                          128))
             ENDDO

/*  PIR0138 Error deleting files. Manual cleanup required.                    */

             CHGVAR     VAR(&MSGID) VALUE('PIR0138')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error deleting files for: &1. Manual +
                          cleanup required.') SECLVL('Cause . . . . +
                          . :   An error occured while deleting +
                          files from import directory. &N Recovery +
                          . . . : Check for previous messages in +
                          appropriate message queues for additional +
                          details. File &1 must be deleted +
                          manually. Use cmd WRKLNK to delete file. +
                          Correct errors and then try your request +
                          again.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0141 *Warning* Slot StuffIt3 File not found. Slot Upd not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0141')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Slot file: &1 not found. +
                          Import Slot StuffIt3 Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the Slot +
                          file with the import data is missing. &N +
                          Recovery . . . : Verify Host processes +
                          are properly creating data file. File +
                          name from semaphore file must match +
                          Import Slot StuffIt3 file name minus S prefix. +
                          Re-run Host process to create Import Slot +
                          StuffIt3 Update file and check messages after file +
                          has been created. Use cmd WRKLNK to +
                          verify files exist in correct +
                          directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0142 Error copying files. Import Slot StuffIt3 Update not processed.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0142')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copying files for: &1. Import +
                          Slot StuffIt3 Update not processed.') +
                          SECLVL('Cause . . . . . :   An error +
                          occured while copying files from import +
                          directory to import data files. &N +
                          Recovery . . . : Check for previous +
                          messages in message queues IMPSTUF and +
                          IMPSTUFERR for additional details. +
                          Semaphore file renamed to Err_&1. +
                          Semaphore file and import data file not +
                          deleted from directory. Semaphore file +
                          and import data file will need to be +
                          deleted manually. Use cmd WRKLNK to +
                          delete files. Correct errors and then try +
                          your request again.') SEV(30) FMT((*CHAR +
                          128))
             ENDDO

/*  PIR0143 Item Must Be Repack Item Type 'R'             */

             CHGVAR     VAR(&MSGID) VALUE('PIR0143')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be Repack Item.') +
                          SECLVL('Cause . . . . . :   &1 must be Item +
                          Type R Repack. +
                          &N Recovery  . . . :   Enter a Repack +
                          Item or press F12 to cancel.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0144 uci must be flagged as in stock               */

             CHGVAR     VAR(&MSGID) VALUE('PIR0144')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must in stock.') +
                          SECLVL('Cause . . . . . :   &1 sock code is +
                          " " or "N". +
                          &N Recovery  . . . :   Change the stock +
                          flag to "Y".') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0145 uci number is invalid                         */

             CHGVAR     VAR(&MSGID) VALUE('PIR0145')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          in not found.') +
                          SECLVL('Cause . . . . . :   &1 not found +
                          in the UCI file. +
                          &N Recovery  . . . :   Add uci number +
                          using the UCI Maintenance program.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0146 license number already entered                */

             CHGVAR     VAR(&MSGID) VALUE('PIR0146')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 already assigned to +
                          transaction &2.') SECLVL('Cause . . . . . +
                          :   License &1 was previously assigned to +
                          transaction &2. &N Recovery  . . . :   +
                          Scan a different license number not +
                          assigned to a transaction.') SEV(30) +
                          FMT((*CHAR 15) (*CHAR 7))
             ENDDO

/*  PIR0147 Unload seq of zero is not valid            */

             CHGVAR     VAR(&MSGID) VALUE('PIR0147')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unload sequence zero is invalid') +
                          SECLVL('Enter an unload sequence greater +
                          than zero.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 7))
             ENDDO

/*  PIR0148  User not athorized to use option/function */

             CHGVAR     VAR(&MSGID) VALUE('PIR0148')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('User +
                          &1 is not authorized to use &2.') +
                          SECLVL('Cause . . . . . :   User &1 has +
                          not been given the authority to use &2. +
                          &N Recovery  . . . :   Contact the IT +
                          manager for further assistance.') SEV(30) +
                          FMT((*CHAR 10) (*CHAR 30))
             ENDDO

/*  PIR0149 Value for field must be P, O, OR B */

             CHGVAR     VAR(&MSGID) VALUE('PIR0149')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''P, O, +
                          or B''') SECLVL('Cause . . . . . :   The +
                          value entered for &1 is not valid. &N +
                          Recovery  . . . :   Enter either a ''P'' +
                          or ''O'' or ''B''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR0150 Value for field must be O, E, OR B */

             CHGVAR     VAR(&MSGID) VALUE('PIR0150')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''O, E, +
                          or B''') SECLVL('Cause . . . . . :   The +
                          value entered for &1 is not valid. &N +
                          Recovery  . . . :   Enter either a ''O'' +
                          or ''E'' or ''B''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR0151 Value for field must be H, U */

             CHGVAR     VAR(&MSGID) VALUE('PIR0151')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''H or +
                          U''') SECLVL('Cause . . . . . :   The +
                          value entered for &1 is not valid. &N +
                          Recovery  . . . :   Enter either a ''H'' +
                          or ''U''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR0152 Value for field must be H, U */

             CHGVAR     VAR(&MSGID) VALUE('PIR0152')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''L or +
                          S''') SECLVL('Cause . . . . . :   The +
                          value entered for &1 is not valid. &N +
                          Recovery  . . . :   Enter either a ''L'' +
                          or ''S''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR0153 Slot qty changed, unavailable for replenishment (640b) */

             CHGVAR     VAR(&MSGID) VALUE('PIR0153')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot Qty changed &1 unavailable for +
                          replenishment.') SECLVL('Cause . . . . . +   +
                          :   The slot &1 you have selected is +
                          unavailable for replenishment because the +
                          slot quantity changed. &N +
                          Recovery  . . . :   Cancel +
                           and try your request +
                          again.') SEV(40) FMT((*CHAR 12))
             ENDDO
/*  PIR0201 Value can not be blank for create operation.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0201')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be entered for Create operation.') +
                          SECLVL('Cause . . . . . :   &1 can not be +
                          blank or less than zero for a create +
                          operation. &N Recovery  . . . :   Enter a +
                          value for &1 or press F12 to cancel.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0202 Value can not already exist for a create operation.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0202')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          already exists.') SECLVL('Cause . . . . . +
                          :   &1 already exists. &N Recovery  . . . +
                          :   Enter a value for &1 that does not +
                          already exist or press F12 to cancel.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0203 Value can not be blank.                       */

             CHGVAR     VAR(&MSGID) VALUE('PIR0203')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be entered.') SECLVL('Cause . . . . +
                          . :   &1 can not be blank. &N Recovery  . +
                          . . :   Enter a value for &1 or press F12 +
                          to cancel.') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0204 Can only enter one value.                     */

             CHGVAR     VAR(&MSGID) VALUE('PIR0204')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Only +
                          one value can be entered.') SECLVL('Cause . +
                           . . . . :   More than one value was +
                          entered. &N Recovery . . . : +
                          Enter only one value.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0205 Must enter at least one value.                */

             CHGVAR     VAR(&MSGID) VALUE('PIR0205')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Must +
                          enter at least one value.') SECLVL('Cause . +
                           . . . . :   No value was entered +
                          . &N Recovery . . . : +
                          Enter at least one value.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO
/*  PIR0206 Value can not be ...                          */

             CHGVAR     VAR(&MSGID) VALUE('PIR0206')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Value +
                          can not be &1.') SECLVL('Cause . . . +
                          . :   Value can not be &1. &N Recovery  . +
                          . . :   Enter a value not &1 or press F12 +
                          to cancel.') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0750 Records removed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0750')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          &2 were removed.') SEV(00) FMT((*DEC 5 0) +
                          (*CHAR 45))
             ENDDO

/*  PIR0751 Records removed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0751')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          &2 were removed.') SEV(00) FMT((*DEC 7 0) +
                          (*CHAR 46))
             ENDDO

/*  PIR0752 Records removed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0752')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          &2 were removed.') SEV(00) FMT((*DEC 9 0) +
                          (*CHAR 46))
             ENDDO

/*  PIR1001 Invalid value entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid value entered for &1') +
                          SECLVL('Cause . . . . . :   The value +
                          entered for &1 is not valid. &N Recovery  +
                          . . . :   Enter a new value which is +
                          valid or press F4 if it is available to +
                          see a list of valid values and select +
                          one.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1002 Invalid date entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid date entered') SECLVL('Cause +
                          . . . . . :  ''&1'' is not a valid date. +
                          &N Recovery  . . . :   Enter a new date +
                          in MMDDYY format or have the system +
                          create a date for you by entering 30D (30 +
                          days from today), 1W (1 week from today) +
                          or 1M (1 month from today).') SEV(30) +
                          FMT((*CHAR 6))
             ENDDO

/*  PIR1003 Invalid time entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1003')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid time entered') SECLVL('Cause +
                          . . . . . :  ''&1 &2'' is not a valid +
                          time. &N Recovery  . . . :   Enter a new +
                          time in HHMM A/P format where A/P +
                          indicates Am/Pm.') SEV(30) FMT((*CHAR 4) +
                          (*CHAR 1))
             ENDDO
/*  PIR1004 Receving label program has not been defined. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1004')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Receiving label program has not been +
                          defined.') SECLVL('Cause . . . . . :  A +
                          program has not been defined to print +
                          receiving labels. &N Recovery  . . . :  +
                          You can continue processing without +
                          printing labels. Otherwise, see the data +
                          processing manager to define the +
                          receiving label using the administration +
                          menu.') SEV(00)
             ENDDO

/*  PIR1005 Value for field must be Y or N.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1005')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''Y'' or +
                          ''N''') SECLVL('Cause . . . . . :   The +
                          value entered for &1 is not valid. &N +
                          Recovery  . . . :   Enter either a ''Y'' +
                          or ''N''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1006 Value for jobq not valid for view report option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1006')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for jobq not valid for view +
                          report option.') SECLVL('Cause . . . . . +
                          :   Cannot put the report on jobq, if you +
                          want to view this report. &N Recovery  . +
                          . . :   Enter a ''N'' for jobq +
                          option.') SEV(30)
             ENDDO

/*  PIR1007 Invalid date entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1007')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid date entered') SECLVL('Cause +
                          . . . . . :  ''&1'' is not a valid +
                          date. &N Recovery  . . . :   Enter a new +
                          date in MMDDYY format.') SEV(30) +
                          FMT((*CHAR 6))
             ENDDO

/*  PIR1008 Date cannot be blank.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1008')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Date +
                          is required.') SECLVL('Cause . . . . . :  +
                          Date entered is blank or zero. &N +
                          Recovery  . . . :   Enter a new date in +
                          MMDDYY format.') SEV(30)
             ENDDO

/*  PIR1009 Date must be > today.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1009')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Date +
                          must be greater than today.') SECLVL('Cause +
                           . . . . . :  Date entered is not greater +
                          than today. &N +
                          Recovery  . . . :   Enter a new date in +
                          MMDDYY format.') SEV(30)
             ENDDO

/*  PIR1010 Date must be < today.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1010')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Date +
                          must be less than or equal to today.') +
                          SECLVL('Cause . . . . . :  Date entered +
                          is not less than or equal to today. &N +
                          Recovery  . . . :   Enter a new date in +
                          MMDDYY format.') SEV(30)
             ENDDO

/*  PIR1011 Value for update label must be Y if slot merge out = N */

             CHGVAR     VAR(&MSGID) VALUE('PIR1011')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''Y'' ') +
                          SECLVL('Cause . . . . . :   The value in +
                          field Slot marked out is ''N''. &N +
                          Recovery  . . . :   Enter ''Y'' in field +
                          &1.') SEV(30) FMT((*CHAR 50))

             ENDDO

/*  PIR1012 Value for field must be 1, 2, OR 3 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1012')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''1, 2, +
                          or 3''') SECLVL('Cause . . . . . :   The +
                          value entered for &1 is not valid. &N +
                          Recovery  . . . :   Enter either a ''1'' +
                          or ''2'' or ''3''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1013 Value for field must be 0, 1, OR 2 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1013')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Value for field &1 must be ''0, 1, +
                          or 2''') SECLVL('Cause . . . . . :   The +
                          value entered for &1 is not valid. &N +
                          Recovery  . . . :   Enter either a ''0'' +
                          or ''1'' or ''2''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1014 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1014')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option &1 is not valid.') +
                          SECLVL('Cause . . . . . :   Reprint Tags +
                          is only valid with Items that have a +
                          Category Code of CLAMS. &N Recovery  . . +
                          . :   Retry option with a different Item +
                          that has a Category code of CLAMS.') +
                          SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1015 Truck Compartment must be blank. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1015')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be blank.') SECLVL('Cause . . . . . +
                          :   Tote is selected. &N Recovery  . . . +
                          :   Blank out &1 .') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR1016 Field 1 must be less than or equal to field 2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1016')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be less than or equal to &2.') +
                          SECLVL('Cause . . . . . :   The value you +
                          entered for &1 (&3) must be less than or +
                          equal to the value entered for &2 (&4). +
                          &N Recovery  . . . :   Enter a value that +
                          is less than &2.') SEV(30) FMT((*CHAR 20) +
                          (*CHAR 20) (*DEC 4) (*DEC 4))
             ENDDO

/*  PIR1017 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1017')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option &1 is not available for +
                          Templates.') SECLVL('Cause . . . . . :   +
                          The option you entered  is not valid for +
                          template codes. &N Recovery  . . . :   +
                          Try another valid option other than 6 or +
                          12 for this record.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1018 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1018')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option &1 is not available for +
                          Trucks.') SECLVL('Cause . . . . . :   The +
                          option you entered  is not valid for +
                          trucks. &N Recovery  . . . :   Try +
                          another valid option other than 2, 3, or +
                          4 for this record.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1019 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1019')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Copying a template to a truck not +
                          allowed.') SECLVL('Cause . . . . . :   +
                          You can not create a truck from a +
                          template. &N Recovery  . . . :   Enter +
                          another template.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1020 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1020')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option &1 is only available for +
                          Totes.') SECLVL('Cause . . . . . :   The +
                          option you entered  is only for totes. &N +
                          Recovery  . . . :   Try another valid +
                          option other than 12 for this record.') +
                          SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1021 Invalid designation type entered. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid designation type entered') +
                          SECLVL('Cause . . . . . :   Designation type +
                          must be a ''H'' or ''S''. &N Recovery  . +
                          . . :   Enter ''H'' for hard designation or ''S'' +
                          for soft designation.') SEV(30)
             ENDDO

/*  PIR1022 Invalid template code             */

             CHGVAR     VAR(&MSGID) VALUE('PIR1022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid template code entered.') +
                          SECLVL('Cause . . . . . :   Template code +
                          entered does not exist. &N Recovery  . . +
                          . :   Enter a Template code previously +
                          entered.') SEV(30)
             ENDDO

/*  PIR1023 Template Required for Trucks      */

             CHGVAR     VAR(&MSGID) VALUE('PIR1023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Template code required.') +
                          SECLVL('Cause . . . . . :   Template code +
                          is required when Entering/Maintaining +
                          Trucks. &N Recovery  . . . :   Enter a +
                          valid Template code.') SEV(30)
             ENDDO

/*  PIR1051 Inactive slot unavailable for replenishment */

             CHGVAR     VAR(&MSGID) VALUE('PIR1051')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Inactive slot &1 unavailable for +
                          replenishment.') SECLVL('Cause . . . . . +   +
                          :   The slot &1 you have selected is +
                          unavailable for replenishment because the +
                          slot is not at active status. &N +
                          Recovery  . . . :   Select a slot that +
                          has a status of "A" and try your request +
                          again.') SEV(40) FMT((*CHAR 12))
             ENDDO

/*  PIR1052 New pallet for each aisle not avail. when Build method not 2=Loc */

             CHGVAR     VAR(&MSGID) VALUE('PIR1052')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('New +
                          pallet for each aisle=Y is not allowed +
                          unless Build method = 2.') SECLVL('Cause +
                          . . . . .  :   New pallet for each aisle +
                          is only allowed when Build Method is +
                          2=Location. &N Recovery  . . . :   Change +
                          Build Method to 2=Location or change New +
                          pallet for each aisle to N=No and try +
                          your request again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1053 Dock door selected is inactive. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1053')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Dock +
                          door &1 is inactive. Select new door.') +
                          SECLVL('Cause . . . . . :   The dock door +
                          &1 you have selected is not available +
                          because the dock door is inactive. &N +
                          Recovery  . . . :   Enter a dock door +
                          that is active or press F4=Prompt to +
                          select an available dock door and try +
                          your request again.') SEV(30) FMT((*DEC 3))
             ENDDO

/*  PIR1054 Not all dock door(s) assigned. Pick & print halted for route. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1054')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Not +
                          all dock door(s) assigned. Pick & print +
                          halted for route-&1.') SECLVL('Cause . . +
                          . . . :   Not all truck compartments for +
                          route-& have a dock door assigned for +
                          loading. &N Recovery  . . . :   Enter +
                          option 11=Work with dock doors for +
                          route-&1 to find the compartment(s) +
                          missing a dock door. Enter valid door(s) +
                          for the affected compartments. Then take +
                          option 1=Pick and print for route-&1 and +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 5))
             ENDDO

/*  PIR1055 Option not allowed on dock door. No route assigned to door. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1055')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option &1 not allowed on dock +
                          door-&2. No route assigned to door.') +
                          SECLVL('Cause . . . . . :   This option +
                          is not available for the dock door +
                          selected because no route has been +
                          assigned to this dock door. &N Recovery  +
                          . . . :   Enter option &1 next to a dock +
                          door that has a route assigned to it and +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 10) (*DEC 3))
             ENDDO

/*  PIR1056 Option not allowed on dock door. Option x available. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1056')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option &1 not allowed on dock +
                          door-&2. Option &3 available.') +
                          SECLVL('Cause . . . . . :   You have +
                          selected an option that is not available +
                          for one of the following reasons: &N 1.) +
                          You are in View only mode. &N 2.) The +
                          route assigned to the door you are +
                          attempting to change is no longer at +
                          Built status. Changing of assigned dock +
                          doors is not allowed after the route is +
                          no longer at Built status. &N Recovery  . +
                          . . :   Change your request to option &3 +
                          or select a door with a route that is +
                          still at Built status and try your +
                          request again.') SEV(30) FMT((*CHAR 10) +
                          (*DEC 3) (*CHAR 10))
             ENDDO

/*  PIR1057 License Plate Tracking = No. All options must be No. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1057')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Allow License Plate Tracking is +
                          N=No. All other options must be N=No.') +
                          SECLVL('Cause . . . . . :   You have set +
                          one or more of the following options to +
                          Y=Yes: Track all items, Track all date +
                          sensitive items, Track all lot code items +
                          or Track all catchweight items to Y=Yes. +
                          &N Recovery  . . . :   Change all license +
                          plate tracking options to N=No or Change +
                          Allow License Plate Tracking to Y=Yes. +
                          Then try your request again.') SEV(30) +
                          FMT(*NONE)
             ENDDO

/*  PIR1058 License Plate Tracking Yes, At least one option must be Yes. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1058')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('At +
                          least one tracking option must be set to +
                          Y=Yes.') SECLVL('Cause . . . . . :   You +
                          have set all options for license plate +
                          tracking to N=No. &N Recovery  . . . :   +
                          Change at least one license plate +
                          tracking option to Y=Yes or change Allow +
                          license plate tracking to N=No. Then try +
                          your request again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1059 Date Sensitive,Lot Tracking and Catchweight items must be Yes. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1059')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Date +
                          sensitive, Lot code and Catchweight items +
                          must be Y=Yes.') SECLVL('Cause . . . . . +
                          :   You have set the option for Track all +
                          items to Y=Yes. &N Recovery  . . . :   +
                          Change all license plate tracking options +
                          to Y=Yes or change Track all items to +
                          N=No and set one or more of the following +
                          to Y=Yes: Track date sensitive items, Lot +
                          code items or Catchweight items. Then try +
                          your request again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1060 Quantity change not allowed when runner flag = 'F'.            */

             CHGVAR     VAR(&MSGID) VALUE('PIR1060')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity change not allowed when +
                          runner flag = "F".') SECLVL('Cause . . . +
                          . . :   Runner flag has been created for +
                          short/out quantity. Until this flag has +
                          been cleared by the Clear Flag Entries +
                          program the quantity cannot be changed. +
                          &N Recovery  . . . :   Go to the PIRFLG +
                          menu, take the option for Select Flag +
                          Task list. Next position to the +
                          department and label number in question. +
                          Press F11=View till you see the +
                          transaction number assigned to this item. +
                          Then go into the Clear Flag Entries +
                          program to clear the flag. Then try your +
                          request again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1061 Runner flag not closed. F7=Clear flag not available.           */

             CHGVAR     VAR(&MSGID) VALUE('PIR1061')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Runner flag not closed. F7=Clear +
                          flag not available.') SECLVL('Cause . . . +
                          . . :   Runner flag has been created for +
                          short/out quantity. Until this flag has +
                          been cleared by the Clear Flag Entries +
                          program the flag cannot be cleared. &N +
                          Recovery  . . . :   Go to the PIRFLG +
                          menu, take the option for Select Flag +
                          Task list. Next position to the +
                          department and label number in question. +
                          Press F11=View till you see the +
                          transaction number assigned to this item. +
                          Then go into the Clear Flag Entries +
                          program to clear the flag. Then try your +
                          request again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1062 New pallet for each order only when Build method is 1/3 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1062')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('New +
                          pallet for each order only allowed for +
                          Build method = 1 or 3.') SECLVL('Cause . +
                          . . . .  :   New pallet for each order is +
                          only allowed when Build Method is 1=Stop +
                          or 3=Desc by Stop. &N Recovery  . . . :   +
                          Change Build Method to 1=Stop or 3=Desc +
                          by Stop or change New pallet for each +
                          order to N=No and try your request +
                          again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1063 New pallet if stop doesn't fit, only when Build method is 1/3  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1063')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('New +
                          pallet if stop does not fit only allowed +
                          for Build method = 1 or 3.') +
                          SECLVL('Cause . . . . .  :   New pallet +
                          if stop does not fit is only allowed when +
                          Build Method is 1=Stop or 3=Desc by Stop. +
                          &N Recovery  . . . :   Change Build +
                          Method to 1=Stop or 3=Desc by Stop or +
                          change New pallet if stop does not fit to +
                          N=No and try your request again.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1064 Stop must be 1 when new pallet for order = Y  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1064')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Stop +
                          must be 1 when new pallet for order = +
                          Y.') SECLVL('Cause . . . . .  :   Stop is +
                          greater than 1 and new pallet for order +
                          is  set to Y. &N Recovery  . . . :   +
                          Change stops to 1 or change new pallet +
                          for order to Y=Yes and try your request +
                          again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1393 User Profile &1 re-enabled by User Profile &2 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1393')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('User +
                          profile &1 has been re-enabled by user +
                          &2.') SECLVL('Cause . . . . .  :   User +
                          profile &1 has been re-enabled by user +
                          &2. &N Recovery  . . . :   Direct user to +
                          login and resume their duties.') SEV(10) +
                          FMT((*CHAR 10 0) (*CHAR 10 0))          /* (710 A) */

             ENDDO

/*  PIR2007 Invalid slot, slot inactive. */

             CHGVAR     VAR(&MSGID) VALUE('PIR2007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot, slot inactive.') +
                          SECLVL('Cause . . . . . :   The scanned +
                          slot is inactive. Cannot transfer product +
                          from/to an inactive slot. &N Recovery  . +
                          . . :   Scan a new location and try your +
                          request again.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR2101 Invalid value for field 1 based on value for field 2.*/

             CHGVAR     VAR(&MSGID) VALUE('PIR2101')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Invalid value for &1.') +
                          SECLVL('Cause . . . . . :   The value you +
                          entered for &1 cannot be &3 when the value +
                          for &2 is &4. +
                          &N Recovery  . . . :   Enter a new value +
                          for &1 or &3.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  PIR2102 Invalid value for field 1 based on value for field 2.*/

             CHGVAR     VAR(&MSGID) VALUE('PIR2102')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Both +
                          &1 and &2 cannot be entered.') +
                          SECLVL('Cause . . . . . :   Both &1 and +
                          &2 cannot be entered. &N Recovery  . . . +
                          :   Remove the value for &1 or &2.') +
                          SEV(30) FMT((*CHAR 20 0) (*CHAR 20 0) +
                          (*CHAR 5 0) (*CHAR 5 0))
             ENDDO
/*  PIR2103 Answer type cannot be changed while validation entries exist */

             CHGVAR     VAR(&MSGID) VALUE('PIR2103')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Answer Type cannot be changed +
                          while validation entries exist.') +
                          SECLVL('Cause . . . . . :   Validation +
                          Entries exist for this questions answer +
                          type...Delete the validation entries +
                          before changing the answer type.') +
                          SEV(30) FMT((*CHAR 20 0) (*CHAR 20 0) +
                          (*CHAR 5 0) (*CHAR 5 0))
             ENDDO
/*  PIR2104 Item for license scanned does not eqaul item required */

             CHGVAR     VAR(&MSGID) VALUE('PIR2104')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          for license scanned does not equal item +
                          required.') SECLVL('Cause . . . . . :   +
                          The scanned license has a different item +
                          that does not match the required item to +
                          be pulled.') SEV(30) FMT((*CHAR 20 0) +
                          (*CHAR 20 0) (*CHAR 5 0) (*CHAR 5 0))
             ENDDO
/*  PIR2105 License scanned has a FIFO date that is out of sequence */

             CHGVAR     VAR(&MSGID) VALUE('PIR2105')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License scanned has a FIFO date that +
                          is out of sequence.') SECLVL('Cause . . . +
                          . . :   The scanned license has a FIFO +
                          date that does not follow slot rules.') +
                          SEV(30) FMT((*CHAR 20 0) (*CHAR 20 0) +
                          (*CHAR 5 0) (*CHAR 5 0))
             ENDDO
/*  PIR2106 License scanned has a FIFO date that is out of sequence (F20) */

             CHGVAR     VAR(&MSGID) VALUE('PIR2106')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License scanned has a FIFO date that +
                          is out of sequence, press F20 to +
                          override.') SECLVL('Cause . . . . . :   +
                          The scanned license has a FIFO date that +
                          does not follow slot rules. You can +
                          override and accept the scnanned license +
                          by pressing F20. An exception record will +
                          be written to the exception file.') +
                          SEV(30) FMT((*CHAR 20 0) (*CHAR 20 0) +
                          (*CHAR 5 0) (*CHAR 5 0))
             ENDDO
/*  PIR4001 Notify supervisor of condition, Warning. */

             CHGVAR     VAR(&MSGID) VALUE('PIR4001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Notify supervisor of condition.') +
                          SECLVL('Cause . . . . . :   Unexpected +
                          response entered. Please notify your +
                          supervisor before continuing. &N Recovery  . +
                          . . :   Change response or press +
                          override.') SEV(30) FMT(*NONE)
             ENDDO


/*  PIR4002 Invalid value for field 1 based on value for field 2.*/

             CHGVAR     VAR(&MSGID) VALUE('PIR4002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Product expired.') +
                          SECLVL('Cause . . . . . :   The manufac+
                          turer date entered shows product already +
                          expired. &N Recovery  . +
                          . . :   Enter new date or change +
                          putaway to N.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR7871 Subfile record could not be added to file. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7871')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          was not added to file.') SECLVL('Cause . +
                          . . . . :   An error occured while trying +
                          to add &1. &N Recovery  . . . :   Press +
                          ENTER to try again or contact your DP +
                          manager for further instructions.') +
                          SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7872 Subfile record could not be updated in file. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7872')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          was not updated in file.') SECLVL('Cause +
                          . . . . . :   An error occured while +
                          trying to update &1. &N Recovery  . . . +
                          :   Press ENTER to try again or contact +
                          your DP manager for further +
                          instructions.') SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7971 Record not added to file.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7971')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Record was not added to file.') +
                          SECLVL('Cause . . . . . :   An error +
                          occured while trying to add the record +
                          you just entered. &N Recovery  . . . :   +
                          Contact your DP manager for +
                          instructions.') SEV(40)
             ENDDO

/*  PIR7972 Record not updated in file.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7972')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Record was not updated in file.') +
                          SECLVL('Cause . . . . . :   An error +
                          occured while trying to update the record +
                          you were workin on. &N Recovery  . . . +
                          :   Contact your DP manager for recovery +
                          instructions.') SEV(40)
             ENDDO

/*  PIR7973 Record selected does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7973')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          record you selected does not exist.') +
                          SECLVL('Cause . . . . . :   The record +
                          you selected could not be found. The most +
                          common cause for this is that someone +
                          deleted the record between the time it +
                          was displayed on your screen and the time +
                          you selected it. &N Recovery  . . . :   +
                          Press F5 to refresh your screen. The +
                          record will be gone if it was deleted.  +
                          If it still is displayed try selecting it +
                          again. If this error still occurs then +
                          contact your D.P. manager.') SEV(40) +
                          FMT((*DEC 9 0))
             ENDDO

/*  PIR7974 Record selected is locked.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7974')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          record you selected is locked by another +
                          user.') SECLVL('Cause . . . . . :   +
                          Another user is already using the record +
                          you selected and it can not be shared. &N +
                          Recovery  . . . :   Select another record +
                          or wait until the other user is finished +
                          and try again. If no other user is using +
                          the record and you still receive this +
                          message then contact your D.P. manager.') +
                          SEV(40)
             ENDDO

/*  PIR7975 Record not deleted.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7975')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Record was not deleted.') +
                          SECLVL('Cause . . . . . :   No further +
                          information. &N Recovery  . . . :   +
                          Contact your D.P. manager.') SEV(40)
             ENDDO

/*  PIR7978  Record in use. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7978')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          record already in use.') SECLVL('Cause . +
                          . . . . :   The &1 record is being used +
                          by another user. &N Recovery  . . . :   +
                          Wait until the &1 record is not being +
                          used and try again.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR7979 record does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7979')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          record does not exist.') SECLVL('Cause . +
                          . . . . :   The &1 record is needed for +
                          this update but it does not exist. &N +
                          Recovery  . . . :   Create the &1 record +
                          and try again.') SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7980  Item quantity record in use. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7980')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity for item &1 could not be +
                          adjusted.') SECLVL('Cause . . . . . :   +
                          The quantity for item &1 could not be +
                          adjust because the item''s quantity +
                          record is in use by another user. &N +
                          Recovery  . . . :   Try again.  If you +
                          get this message again contact the DP +
                          Manageer.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR7981 Item quantity record does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7981')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity for item &1 could not be +
                          adjusted.') SECLVL('Cause . . . . . :   +
                          The quantity for item &1 could not be +
                          adjusted because the item quantity record +
                          needed for this update does not exist. &N +
                          Recovery  . . . :   Have the DP Manager +
                          create the necessary item quantity record +
                          for &1 in file ITEMQTY and try again.') +
                          SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7982 Record changed by another user.      */

             CHGVAR     VAR(&MSGID) VALUE('PIR7982')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Record changed by another +
                          user before update could be made.') +
                          SECLVL('Cause . . . . . :   The current +
                          information for the record you are updating +
                          changed before you pressed Enter to make +
                          your update. &N Recovery  . . . :   +
                          Press F20 to accept the warning and make +
                          the adjustment or press F12 to cancel.') +
                          SEV(10)
             ENDDO

/*  PIR7983 Record changed by another user.      */   /* 415 A */

             CHGVAR     VAR(&MSGID) VALUE('PIR7983')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Record changed by another +
                          user before update could be made.') +
                          SECLVL('Cause . . . . . :   The current +
                          information for the record you are +
                          updating changed before you pressed Enter +
                          to make your update. &N Recovery  . . . +
                          :   Press F5 to refresh the screen with +
                          the current values. Make your changes. +
                          Press Enter to save the changes.') SEV(10)
             ENDDO


/*  PIR9801 Program canceled at your request.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9801')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          canceled at your request.') SECLVL('No +
                          further information for this message.') +
                          SEV(0) FMT((*CHAR 50))
             ENDDO

/*  PIR9802 Program ended in error.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9802')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          ended in error.') SECLVL('No further +
                          information for this message.') SEV(40) +
                          FMT((*CHAR 50))
             ENDDO

/*  PIR9803 Delete completed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9803')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          deleted successfully.') SECLVL('No +
                          further information for this message.') +
                          SEV(00) FMT((*CHAR 50))
             ENDDO

/*  PIR9804 Invalid option sent to program. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9804')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid option (&1) sent to program +
                          &2') SECLVL('Contact you D.P. manager for +
                          futher assistance.''') SEV(40) FMT((*CHAR +
                          8) (*CHAR 10))
             ENDDO

/*  PIR9805 No records found for subfile display. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9805')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          records found for file &1') +
                          SECLVL('Correct the parameters and try +
                          your request again.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR9806 No records found for entered criteria. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9806')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          records found for entered criteria') +
                          SECLVL('Correct the parameters and try +
                          your request again.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR9901 FROM date must be < or = to the TO date.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9901')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('FROM date must be less than or equal +
                          to the TO date.') SECLVL('Cause . . . . . +
                          :   You have entered a FROM date that is +
                          greater than the TO date. &N Recovery  . +
                          . . :   Enter a new date that is less than +
                          or equal to the TO date.') SEV(40)
             ENDDO

/*  PIR9902 FROM time must be < or = to the TO time. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9902')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('FROM time must be less than or equal +
                          to the TO time.') SECLVL('Cause . . . . . +
                          :   You have entered a FROM time that is +
                          greater than the TO time. &N Recovery  . +
                          . . :   Enter a new FROM time so that it +
                          is less than or equal to the TO time.') +
                          SEV(40)
             ENDDO

/*  PIR9903 Select one option.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9903')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Select one option.') SECLVL('Cause . +
                          . . . . :   You have not selected any +
                          option. &N Recovery  . . . :   Select one +
                          option to proceed or press F12 to +
                          cancel.') SEV(40)
             ENDDO


/*  PIR9904 Select only one option.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9904')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Select only one option.') +
                          SECLVL('Cause . . . . . :   You have +
                          selected more than one options. &N +
                          Recovery  . . . :   Select only one of the +
                          displayed options to proceed.') SEV(40)
             ENDDO

/*  PIR9905 Cursor position not allowed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9905')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cursor position not allowed for list +
                          request.') SECLVL('Cause . . . . . :   F4 +
                          was pressed, but the cursor was not on a +
                          line with an input field that allows a +
                          list request. &N Recovery  . . . :   +
                          Position the cursor on an input field +
                          that allows a list request before +
                          pressing F4 again.') SEV(40)
             ENDDO

/*  PIR9906 Invalid date entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9906')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid date entered') SECLVL('Cause +
                          . . . . . :  ''''&1'''' is not a valid +
                          date. &N Recovery  . . . :   Enter a new +
                          date in MMDDYY format and try your +
                          request again.') SEV(30) FMT((*CHAR 6))
             ENDDO

/*  PIR9907 &1 No longer at status of &2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9907')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          no longer at status of &2.') +
                          SECLVL('Cause . . . . . :  Someone has +
                          already selected &1 for further +
                          processing and it is no longer available. +
                          &N Recovery  . . . :   Press F5=Refresh +
                          to display the current list of &3 +
                          available for further processing.  Then +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9908 &1 currently inuse. &2 in progress. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9908')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          currently inuse. &2 in progress.') +
                          SECLVL('Cause . . . . . :  Someone has +
                          already selected &1 for further +
                          processing and it is no longer available. +
                          &N Recovery  . . . :   Press F5=Refresh +
                          to display the current list of &3 +
                          available for further processing.  Then +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO
/*  PIR9909 &1 Has started transactions.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9909')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          has started transactions.') +
                          SECLVL('Cause . . . . . :  Someone has +
                          already started transactions for &1 +
                          &N Recovery  . . . :   Press F5=Refresh +
                          to display the current list of &3 +
                          available for further processing.  Then +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO
/*  PIR9910 For catch-weight items, use full-screen adj program  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9910')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('For +
                          catch-weight items, use full-screen +
                          adjustment program.') SECLVL('Cause . . . +
                          . . :  You may not adjust the inventory +
                          from the RF screen.  Adjustments must be +
                          made in the full-screen program.') +
                          SEV(30) FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9911 Warehouse/department does not exist                 */

             CHGVAR     VAR(&MSGID) VALUE('PIR9911')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warehouse/Department does not +
                          exist.') SECLVL('Cause . . . . . :  +
                          Please enter a valid warehouse/department +
                          combination.') SEV(30) FMT((*CHAR 20) +
                          (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9912 Warehouse/department/item does not exist             */

             CHGVAR     VAR(&MSGID) VALUE('PIR9912')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warehouse/Department/Item does not +
                          exist.') SECLVL('Cause . . . . . :  +
                          Please enter a valid +
                          warehouse/department/item combination.') +
                          SEV(30) FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9913 Remove from default truck list, then delete.         */

             CHGVAR     VAR(&MSGID) VALUE('PIR9913')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Remove from default truck list, then +
                          delete.') SECLVL('Cause . . . . . :  +
                          Truck is part of a truck list used to +
                          assign defualt trucks.') SEV(30) +
                          FMT((*CHAR 20 0) (*CHAR 20 0) (*CHAR 10 0))
             ENDDO

/*  PIR9999 Generic msgd to display error from program. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9999')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1') +
                          SEV(30) FMT((*CHAR 78))
             ENDDO


             RETURN
             ENDPGM
