/*------------------------------------------------------------------*/
/*  English Version (Spanish version is UTMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  UTMSGD      Create PIRMSGF Message Descriptions UTpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  07 July 1997                                                    */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  Revisions                                                       */
/*                                                                  */
/*    09/27/99  DAS  4.12                                           */
/*      - Added UT21001, UT21002, UT21003 and UT21004.              */
/*    09/18/01  RH   4.16a                                          */
/*      - Added UT82201                                             */
/*    11/15/01  DAS  4.16b                                          */
/*      - Added UT81224                                             */
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

/*  UT21001 Slots cannot be deleted.                 */

             CHGVAR     VAR(&MSGID) VALUE('UT21001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Can +
                          not initialize. No items in selected +
                          slots.') SECLVL('Cause . . . . . :   The +
                          group of slots that you are trying to +
                          initialize do not have contain any items. +
                          Only slots with items are initialized. &N +
                          Recovery  . . . :   Enter another group +
                          of slots and try your request again.') +
                          SEV(30) FMT((*DEC 5 0))
             ENDDO

/*  UT21002 Slots initialized              */

             CHGVAR     VAR(&MSGID) VALUE('UT21002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots successfully initialized.') +
                          SECLVL('Cause . . . . . :   &1 slots +
                          successfully initialized. &N Recovery  . +
                          . . :   Not required.') SEV(10) FMT((*DEC +
                          5 0))
             ENDDO

/*  SL21003 Checking for matching slots.     */

             CHGVAR     VAR(&MSGID) VALUE('UT21003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Checking for matching slots.  Please +
                          be patient.') SEV(10)
             ENDDO

/*  UT21004 Initializing slots.            */

             CHGVAR     VAR(&MSGID) VALUE('UT21004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Initializing selected slots.  Please +
                          be patient.') SEV(10)
             ENDDO

/*  UT81201 Item recalculated successfully. */

             CHGVAR     VAR(&MSGID) VALUE('UT81201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 recalculated successfully') SEV(00) +
                          FMT((*CHAR 15))
             ENDDO

/*  UT81221 Item not recalculated - No ItemQty record. */

             CHGVAR     VAR(&MSGID) VALUE('UT81221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 not recalculated - No ITEMQTY +
                          record.') SECLVL('Cause . . . . . :   An +
                          ITEMQTY record does not exist for item +
                          &1. &N Recovery  . . . :   Create an +
                          ITEMQTY record for &1 and try again.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  UT81222 Item not recalculated - Invalid item. */

             CHGVAR     VAR(&MSGID) VALUE('UT81222')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 not recalculated - Item does not +
                          exist') SECLVL('Cause . . . . . :   &1 is +
                          an invalid item. &N Recovery  . . . :   +
                          Create item &1 and try again.') SEV(30) +
                          FMT((*CHAR 15))
             ENDDO

/*  UT81223 Item not recalculated - Update error. */

             CHGVAR     VAR(&MSGID) VALUE('UT81223')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 not recalculated - Update error') +
                          SECLVL('Cause . . . . . :   An error +
                          occured while trying to update the +
                          ITEMQTY record for item &1. &N Recovery  +
                          . . . :   Make sure an ITEMQTY record +
                          exists for item &1 and that it is not +
                          locked, then try again.') SEV(30) +
                          FMT((*CHAR 15))
             ENDDO

/*  UT81224 Item not recalculated - Tfr qty exists */

             CHGVAR     VAR(&MSGID) VALUE('UT81224')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 not recalculated - Slot transfer +
                          quantity exists') SECLVL('Cause . . . . . +
                          :   A transfer quantity was found in slot +
                          &2/&3 for item &1. Currently this +
                          quantity cannot be traced back to the the +
                          Replenishment, Letdown or Transfer +
                          transaction that generated it. Therefore, +
                          the warehouse quantity cannot be +
                          recalculated accurately. &N Recovery  . . +
                          . :   Close all Replenishment, Letdown +
                          and Transfer transactions for item &1. +
                          Make sure none of the slots for the item +
                          have a transfer quantity and then try +
                          again.') SEV(30) FMT((*CHAR 15) (*CHAR 5) +
                          (*CHAR 12))
             ENDDO

/*  UT82201 Item discrepency checked successfully. */

             CHGVAR     VAR(&MSGID) VALUE('UT82201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 discrepency checked successfully') +
                          SEV(00) FMT((*CHAR 15))
             ENDDO

             RETURN
             ENDPGM
