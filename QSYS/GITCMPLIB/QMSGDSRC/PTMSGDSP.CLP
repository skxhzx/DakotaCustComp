/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to PTMSGD                      */
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
/*  05/24/06  DAS 5.10  Changed &MSGF to PIRMSGSP                   */
/*    07/18/06  JCJ  5.00a                                          */
/*     -  Add PT64007 message.                                      */
/*    11/08/07  RBD  5.10                                           */
/*     -  Add PT13201 message.                                      */
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

/*  PT13010 Transaction can not be closed. Slot not found. */

             CHGVAR     VAR(&MSGID) VALUE('PT13010')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaccion no puede ser terminada. +
                          El slot &1 no encontrado.') SECLVL('Causa +
                          . . . . . :   El slot &1 no existe. &N +
                          Recobro . . . :   Un slot debe ser creado +
                          antes de que pueda terminar esta +
                          transaccion.') SEV(30) +
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
                          MSG('Transaccion no puede ser terminada. +
                          El Slot &1 no contiene el producto &2.') +
                          SECLVL('Causa . . . . .     El slot &1 no +
                          contiene el producto &2 nada mas. &N +
                          Recobro . . . :   Tenga que poner al dia +
                          el producto ntes de que pueda terminar +
                          esta +
                          transaccion.') SEV(30) FMT((*CHAR 12) +
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
                          MSG('Transaccion no puede ser terminada. +
                          Transaccion &1 no encontrado.') +
                          SECLVL('Causa . . . . . : La transaccion +
                          &1 no existe. &N Recobro . . . :   La +
                          anotacion de transaccion debe ser creada +
                          antes de que pueda terminar esta +
                          transaccion.') SEV(30) +
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
                          MSG('Transaccion no puede ser terminada. +
                          El detalle de pedido no fue encontrado por +
                          el producto &1.') SECLVL('Causa . . . . . +
                          :   El detalle de pedido del producto &1 +
                          no existe. &N Recobro . . . :   El detalle +
                          de pedido del producto debe ser creado +
                          antes de que pueda terminar esta +
                          transaccion.') SEV(30) FMT((*CHAR 15))
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
                          MSG('Transaccion no puede ser terminada. +
                          El rotulo &1 no encontrado.') +
                          SECLVL('Causa . . . . . :   El rotulo &1 +
                          no existe. &N Recobro . . . :   La +
                          anotacion de rotulo debe ser creada antes +
                          de que pueda terminar esta transaccion.') +
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
                          MSG('Transaccion no puede ser terminada. +
                          El slot de recepcion &1 no fue +
                          encontrado.') SECLVL('Causa . . . . . . +
                          :   Se esta cerrando una transaccion que +
                          incluye una peticion de transferencia. Sin +
                          embargo, el slot de recepcion no existe. +
                          &N Recobro . . . :   Se ha puesto al dia +
                          todo bien excepto el slot de recibir la +
                          transferencia. Se debe hacer un +
                          ajustamiento manual al slot de recibir +
                          el producto.') SEV(30) FMT((*CHAR +
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
                          MSG('Transaccion no puede ser termindada. +
                          El slot de recepcion &1 no contiene el +
                          producto &2.') SECLVL('Causa . . . . . : +
                          Se esta terminando una transaccion que +
                          incluye una peticion de transferencia. Sin +
                          embargo, el slot de recepcion (&1) no +
                          contiene el producto &2. &N Recobro . . . +
                          :   Se ha puesto al dia todo bien excepto +
                          el slot de recibir la transferencia. Se +
                          debe hacer un ajustamiento manual al slot +
                          de recibir el producto.') +
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
                          MSG('Transaccion no puede ser terminada. +
                          El detalle de PO no encontrado del +
                          producto &1.') SECLVL('Causa . . . . . : +
                          El detalle de PO del producto &1 no +
                          existe. El detalle del PO del producto +
                          debe ser creado antes de que pueda +
                          terminar esta +
                          transaccion.') SEV(30) FMT((*CHAR 15))
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
                          MSG('Transaccion no puede ser terminada. +
                          No hay bastante inventario en el slot.') +
                          SECLVL('Causa . . . . . :   El slot &1 +
                          no contiene bastante inventario por la +
                          cantidad extra incorporada (&2). &N +
                          Recobro . . . :   Se debe ajustar el +
                          inventario del slot &1 antes de que pueda +
                          terminar esta transaccion.') SEV(30) +
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
                          MSG('Aviso: El total del catch weight de +
                          &1 no es entre la escala de mas/menos de +
                          &2/&3.') SECLVL('Causa . . . . . :   El +
                          total del catch weight incorporado (&1) +
                          no es entre la escala de no menos que &4% +
                          o no mas que &5% del catch weight esperado +
                          de &6). &N Recobro  . . . :   Se puede +
                          oprimir F20 para aceptar el aviso sin +
                          cambio, o cambiar el catch weight +
                          incorporado.') SEV(00) +
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
                          MSG('El numero de catch weight incorporado +
                          &1 no es igual a la cantidad escogida de +
                          &2.') SECLVL('Causa . . . . . :   Los +
                          numeros totales del catch weight +
                          incorporado (&1) no son iguales a la +
                          cantidad escogida de &2. &N Recobro . . . +
                          :  Necesite incorporar un catch weight tan +
                          grande como la cantidad escogida.') +
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
                          MSG('Aviso: Peso incorporado &1 no es entre +
                          la escala  -/+ de  &2 / &3.') +
                          SECLVL('Causa . . . . . :   El peso +
                          incorporado (&1) no es entre la escala +
                          de menos que &4 % o mas que +
                          &5 % del peso esperado de +
                          (&6). &N Recobro  . . . :   Puede oprimir +
                          F20 para aceptar el aviso sin cambiarlo, +
                          o cambie el valor de catch +
                          weight <CW> incorporado.') SEV(00) +
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
                          MSG('Transaccion &1 terminada con +
                          exito.') SECLVL('No hay mas +
                          detalles.') SEV(00) FMT((*DEC 7))
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
                          MSG('Transaccion no puede ser terminada. +
                          No hay una cantidad suficiente para +
                          reaprovisionar el slot.') SECLVL('Causa . +
                          . . . . :   No hay una cantidad suficiente +
                          para llenar la cantidad siendo escogida o +
                          transferida del slot &1. El resultado es +
                          una cantidad negativa disponible. &N +
                          Recobro . . . :   Cambie la cantidad de +
                          reaprovisionamiento a una suma mas grande +
                          que o igual a (&2) e intente otra +
                          vez.') SEV(30) FMT((*CHAR 12) (*DEC 7))
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
                          MSG('Transaccion no terminada- la cantidad +
                          de reaprovisionamiento es pequena.') +
                          SECLVL('Causa . . . . . :   No hay una +
                          cantidad bastante &B reaprovisionada al +
                          slot  &B para llenar la cantidad siendo +
                          escogida y &B o transferida del slot &1. +    a +
                          El resultado es una cantidad negativa +
                          disponible. &N Recobro . . . :   Cambie +
                          la cantidad de reaprovisionamiento a una +
                          suma mas grande que o igual a (&2) e +
                          intente otra +
                          vez.') SEV(30) FMT((*CHAR 12) (*DEC 7))
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
                          MSG('Transaccion no puede ser terminada. +
                          Guardar Manual.') SECLVL('Causa . . . . . +
                          :   La transaccion es de guardar manual y +
                          por eso no puede ser terminada aqui. &N +
                          Recovery  . . . :   Use el programa de +
                          guardar y escandir o incorporar el slot +
                          donde guardo` el producto para terminar +
                          la transaccion.') SEV(30) FMT((*CHAR 12) +
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
                          MSG('Transaccion ya cerrada.') +
                          SECLVL('Causa . . . . . +
                          :   La transaccion ya esta cerrada y +
                          no puede incorporar catch weight (CW). +
                          &N Recobro  . . . :   Catch weight (CW) +
                          fue incorporado antes de cerrar la +
                          transaccion.') SEV(30) FMT((*CHAR 12) +
                          (*DEC 7))
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
                          MSG('Vuelto de cliente ha sido exportado +
                          Cambio de la cantidad no es permitido.') +
                          SECLVL('Causa . . . . . :   El vuelto de +
                          cliente ha sido exportado y el valor del +
                          sistema no permite cambios a la cantidad +
                          vuelta si la anotacion del vuelto ha sido +
                          exportada al sistema primero. &N +
                          Recobro  . . . :   Cambie la cantidad +
                          vuelta al valor original y oprima ENTER +
                          para terminar esta transaccion. Entonces +
                          haga un ajustamiento del inventario al +
                          slot donde volvio` el producto.') SEV(30) +
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
                          MSG('Trans. multiple, use Task Entry para +
                          terminar.') SECLVL('Causa . . . . . :   La +
                          transaccion es una multiple. Use Task Entry +
                          para terminarla antes de cerrar. &N Recobro  . +
                          . . :   Termine la transaccion antes de +
                          cerrarla.') SEV(30) FMT(*NONE)
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
                          MSG('Trans multiple existe, no puede cerrar toda.') +
                          SECLVL('Causa . . . . . :   Transacciones multiples +
                          existen.  No puede usar F16 para cerrar todas. Use +
                          Task Entry para termninarlas antes de cerrar. +
                          &N Recobro  . . . :   Use otra opcion para +
                          cerrar.') SEV(30) FMT(*NONE)
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
                          pendiente, Quitelo antes de cerrar.') +
                          SECLVL('Causa . . . . . :   Hay por lo +
                          menos un flag pendiente de esta transaccion. +
                          &N Recobro  . . . :   Cambie la cantidad del +
                          producto con el flag o pongase en el producto +
                          con el flag y oprima F7 para +
                          quitarlo.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Usuario +
                          &1 no es autorizado cerrar transaccion') +
                          SECLVL('Causa . . . . . :   Solo les permite +
                          a algunos usuarios cerrar transactions de +
                          rutas de MEAT-INSP, PRE-PICK y CONTAINER. +
                          &N Recobro  . . . :   Entre en el programa +
                          con un usuario autorizado e intente otra +
                          vez.') SEV(30) FMT((*CHAR 10))
             ENDDO

/*  PT64005 Trans started, cannot close transaction.     */

             CHGVAR     VAR(&MSGID) VALUE('PT64005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Empezo +
                          la transaccion. No puede cerrarla.') +
                          SECLVL('Causa . . . . . :   Empezo la  +
                          transaccion. No puede cerrarla. +
                            &N Recobro  . . . :   Use Task Entry para +
                          terminar la transaccion, o le pregunte al +
                          usuario terminarla.') +
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
                          Anotaciones de WORKSOS estan pendientes, no +
                          puede cerrarlas.') SECLVL('Causa . . . . . :   +
                          Estan trabajando por lo menos un producto de SOS +
                          por esta transaccion.  &N Recobro  . . . :   +
                          Espere hasta que el usuario acabe el +
                          SOS o establezca contacto con el administrario +
                          para quitar la anotacion.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PT64007 WARNING some transactions are not at an Ended Status*/

             CHGVAR     VAR(&MSGID) VALUE('PT64005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Empezo +
                          la transaccion. No puede cerrarla.') +
                          SECLVL('Causa . . . . . :   Empezo la  +
                          transaccion. No puede cerrarla. +
                            &N Recobro  . . . :   Use Task Entry para +
                          terminar la transaccion, o le pregunte al +
                          usuario terminarla.') +
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
                          transacciones y &2 rotulos fueron quitados+
                          .') SEV(00) FMT((*DEC 5 0) (*DEC 5 0))
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
                          MSG('No puede cerrar la transaccion. No +
                          encontro producto &1.') SECLVL('Causa . . . +
                          . . :   Producto &1 no existe. &N Recobro +
                          . . . :   El archivo del producto debe ser +
                          creado antes de que pueda cerrar esta +
                          transaccion.') SEV(30) FMT((*CHAR 15))
             ENDDO

             RETURN
             ENDPGM
