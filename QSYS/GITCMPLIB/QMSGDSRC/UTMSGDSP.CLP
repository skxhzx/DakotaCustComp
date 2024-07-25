/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to UTMSGD                      */
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
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          puede iniciar. No hay productos en los +
                          slots seleccionados.') SECLVL('Causa . . +
                          . . . :   El grupo de slots que intenta +
                          iniciar no contiene ningunos productos. +
                          Solamente los slots con productos pueden +
                          ser iniciados. &N Recobro . . . :    +
                          Incorpore otro grupo de slots e intente +
                          otra vez.') +
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
                          slots iniciados con exito.') +
                          SECLVL('Cause . . . . . :   &1 slots +
                          iniciados con exito. &N Recobro  . +
                          . . :   No requerido.') SEV(10) FMT((*DEC +
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
                          MSG('Buscando slots que corresponden. +
                          Tenga paciencia por favor.') SEV(10)
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
                          MSG('Iniciando los slots seleccionados +
                          Tenga paciencia por favor.') SEV(10)
             ENDDO

/*  UT81201 Item recalculated successfully. */

             CHGVAR     VAR(&MSGID) VALUE('UT81201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 fue recalculado con exito.') +
                          SEV(00) FMT((*CHAR 15))
             ENDDO

/*  UT81221 Item not recalculated - No ItemQty record. */

             CHGVAR     VAR(&MSGID) VALUE('UT81221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSGBFC     MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 no fue recalculado - No hay +
                          anotacion de ITEMQTY.') SECLVL('Causa . . +
                          . . . :   Una anotacion de ITEMQTY no +
                          existe del producto &1. &N Recobro . . . +
                          :   Cree una anotacion de ITEMQTY de &1 e +
                          intente otra vez.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 no fue recalculado - el +
                          producto no existe.') SECLVL('Causa . . . +
                          . . :   &1 es un producto invalido. &N +
                          Recobro . . . :   Cree el producto &1 e +
                          intente otra vez.') SEV(30) +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 no fue recalculado - Error del +
                          puesto al dia.') SECLVL('Causa . . . . . : +
                          Un error ocurrio mientras tratando de +
                          poner al dia la anotacion de ITEMQTY del +
                          producto &1. &N Recobro . . . : Este +
                          seguro que una anotacion de ITEMQTY existe +
                          poe el producto &1 y que no esta cerrada +
                          Entonces intente otra vez.') SEV(30) +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 no fue recalculado - una +
                          cantidad de transferencia de slot +
                          existe.') SECLVL('Causa . . . . . : Una +
                          cantidad de transferencia fue encontrada +
                          en el slot &2/&3 del producto &1. +
                          Actualmente, esta cantidad no puede ser +
                          atribuida a la transaccion de +
                          reaprovisionamiento, Letdown, o +
                          transferencia que creo la cantidad. Por +
                          eso, la cantidad de almacen no puede ser +
                          recalculada con exactitud. &N Recobro . . +
                          . :   Cierre todas las transacciones de +
                          reaprovisionamiento, Letdown, y +
                          transferencia por el producto &1. Este +
                          seguro que ningunos de los slots del +
                          producto tienen una cantidad de +
                          transferencia e intente otra vez.') +
                          SEV(30) FMT((*CHAR 15) (*CHAR 5) +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          discrepancia del producto &1 fue +
                          verificada con exito.') +
                          SEV(00) FMT((*CHAR 15))
             ENDDO

             RETURN
             ENDPGM
