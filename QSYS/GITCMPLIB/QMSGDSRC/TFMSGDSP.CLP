/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to TFMSGD                      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  TFMSGD      Create PIRMSGF Message Descriptions TFpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  01 March, 1996                                                  */
/*  Hemant Kapadia                                                  */
/*                                                                  */
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

/*  TF12201 Cannot edit this transfer order. */

             CHGVAR     VAR(&MSGID) VALUE('TF12201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede revisar este pedido de +
                          transferencia.') SECLVL('Causa . . . . . +
                          :   El numero del pedido de transferencia +
                          &1 es &2. Por eso, no puede ser revisado. +
                          &N Recobro . . . . :   Incorpore un numero +
                          de pedido abierto e intente otra +
                          vez.') SEV(30) FMT((*DEC 7) +
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
                          MSG('El almacen de escoger y pediro no +
                          pueden ser igual.') SECLVL('Causa . . . +
                          . . :   El numero del almacen de escoger +
                          incorporado es igual al almacen de pedir. +
                          &N Recobro . . . . :   Incorpore un numero +
                          de almacen que es diferente que el numero +
                          del almacen de pedir e intente otra +
                          vez.') SEV(30)
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
                          MSG('No puede autorizar la transferencia de +
                          producto &4.') SECLVL('Causa . . . . . :   +
                          La cantidad pedido de producto &4 es &2 que +
                          es mas que la cantidad disponible &3. +
                          &N Recobro . . . . :   Oprima F12 para +
                          cancelar y entonces cambiar la cantidad +
                          pedida para que sea menos que o igual a la +
                          cantidad disponible en el almacen &1. +
                          Entonces intente otra vez.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no existe.') SECLVL('Causa . . . +
                          . . :   El producto no existe en el almacen +
                          &1. &N Recobro . . . . :   Incorpore un +
                          producto que existe en los dos almacenes de +
                          escoger y pedir.') SEV(30) FMT((*DEC 3))
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
                          MSG('La cantidad pedido &2 es mas que la +
                          disponible &3.') SECLVL('Causa . . . . . +
                          :   La cantidad pedido &2 es mas que la +
                          cantidad disponible &3 del almacen &1. +
                          &N Recobro . . . . :   Incorpore una +
                          cantidad que es menos que o igual a la +
                          cantidad +
                          disponible.') SEV(30) FMT((*DEC 3) (*DEC 7 +
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
                          MSG('El numero de transferencia &1 no +
                          existe.') SECLVL('Causa . . . . . :   El +
                          numero del pedido de transferencia &1 no +
                          fue encontrado. &N Recobro . . . . :   +
                          Incorpore un numero del pedido de +
                          transferencia e intente otra +
                          vez.') SEV(30) FMT((*DEC 7))
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
                          MSG('Aviso: La cantidad recibida no es +
                          igual a la cantidad pedida.') +
                          SECLVL('Causa . . . . . :   La cantidad +
                          recibida es mas grande que o menos que la +
                          cantidad pedida. &N Recobro . . . . +
                          :   Oprima F20 para aceptar el aviso y +
                          recibir la cantidad incorporada u oprima +
                          F12 para cancelar.') SEV(10)
             ENDDO

/*  TF17202 Info. message.                                  */

             CHGVAR     VAR(&MSGID) VALUE('TF17202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 fue recibido y puede ser +
                          combinado con el pedido &2 por +
                          cargamento.') SECLVL('No hay mas +
                          informacion.') SEV(0) FMT((*CHAR +
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
                          MSG('Copiando los pedidos autorizados a los +
                          archivos de escoger.') SEV(00)
             ENDDO

             RETURN
             ENDPGM
