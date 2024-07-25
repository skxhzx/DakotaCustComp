/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to SLMSGD                      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  SLMSGD      Create PIRMSGF Message Descriptions SLpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*                                                                  */
/*   08/23/99  MLB 4.12  Add messages SL16021                       */
/*   01/28/00  DAS 4.13  Add messages SL25201, SL25202, SL25203     */
/*                                    SL25273, SL25274              */
/*   06/12/02  RH  4.16  Add messages SL15201                       */
/*   09/26/02  RH  4.16  Add messages SL26201                       */
/*   12/04/02  RH  4.16  Add messages SL11206                       */
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  CRT0001 Creating slots. */

             CHGVAR     VAR(&MSGID) VALUE('CRT0001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Creando slots.') SECLVL('No hay mas +
                          informacion de este mensaje.') SEV(00)
             ENDDO

/*  CRT0002 Slots created. */

             CHGVAR     VAR(&MSGID) VALUE('CRT0002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots creado.') SECLVL('No hay mas +
                          informacion de este mensaje.') SEV(00) +
                          FMT((*DEC 5))
             ENDDO

/*  CVT0010 Slot number entered incorrectly. */

             CHGVAR     VAR(&MSGID) VALUE('CVT0010')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          &1 fue incorporado incorrecto (&2 invalido+
                          ).') SECLVL('Causa . . . . . :   El slot +
                          &1 no fue incorporado en el formato +
                          correcto por que un valor invalido &2 fue +
                          incorporado. &N Recobro . . . :  Incorpore +
                          el slot en el formato siguiente +
                          : &3.') SEV(30) +
                          FMT((*CHAR 12) (*CHAR 15) (*CHAR 23))
             ENDDO

/*  SL11001 Slot display already exists. */

             CHGVAR     VAR(&MSGID) VALUE('SL11001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          exhibicion de &1 ya existe.') +
                          SECLVL('Causa . . . . . :   El valor de la +
                          exhibicion de slot debe ser unico. &N +
                          Recovery  . . . :   Incorpore un valor +
                          unico por la exhibicion de slot.') SEV(30) +
                          FMT((*CHAR 12))
             ENDDO

/*  SL11201 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El codigo de estado incorporado es +
                          invalido.') SECLVL('Causa . . . . . :   +
                          El codigo de estado no puede ser cambiado +
                          de ''A'' a ''V'', porque hay alguna +
                          cantidad disponible todavia en el slot. &N +
                          Recobro . . . :   Retenga el estado activo +
                          del slot.') SEV(30)
             ENDDO

/*  SL11202 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El codigo de estado incorporado es +
                          invalido.') SECLVL('Causa . . . . . : El +
                          codigo de estado no puede ser cambiado de +
                          ''A'' a ''Z'', porque hay alguna cantidad +
                          disponible todavia en este slot. &N +
                          Recobro . . . :   Oprima F9 para ver las +
                          cantidades del slot.') +
                          SEV(30)
             ENDDO

/*  SL11203 When status is changed to 'Active', an item number  */
/*          must be entered.                                    */

             CHGVAR     VAR(&MSGID) VALUE('SL11203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          numero de producto debe ser incorporado +
                          por slot activo.') SECLVL('Causa . . . . . +
                          :   El numero de producto debe ser +
                          incorporado por el estado de slot ''A'' +
                          (activo). &N Recobro . . . :   Incorpore +
                          un numero de producto valido e intente +
                          otra vez.') SEV(30)
             ENDDO

/*  SL11204 An active Pick slot already exists  for this item in the */
/*          fixed section.                                           */

             CHGVAR     VAR(&MSGID) VALUE('SL11204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          slot de escoger activo ya existe por este +
                          producto en la seccion fija.') +
                          SECLVL('Causa . . . . . :   Un slot de +
                          escoger activo &1 ya existe por este +
                          producto en la seccion fija. No se puede +
                          tener mas que 1 slot de escoger activo por +
                          un producto en la seccion fija. &N Recobro +
                          . . . :   Retenga el estado inactivo del +
                          slot.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  SL11205 Maximum number of pick slots allowed for item has been   */
/*          reached.                                                 */

             CHGVAR     VAR(&MSGID) VALUE('SL11205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El numero maximo de slots de escoger +
                          ya asignado a este producto.') +
                          SECLVL('Causa . . . . . :   Se ha tratado +
                          de asignar un producto a mas slots de +
                          escoger que se permite por este producto. +
                          El numero maximo de slots de escoger es +
                          &1. &N Recobro . . . :   Cambie el slot +
                          a Escoger=N o asigne el producto a un slot +
                          de no escoger. Entonces intente otra +
                          vez.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  SL11206 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL11206')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Codigo de estado invalido ha sido +
                          incorporado.') SECLVL('Causa . . . . . :   +
                          El codigo de estado no puede ser cambiado +
                          de ''A'' a ''V'', use los programas de +
                          verificacion para verificar el slot. &N +
                          Recobro . . . :   Retenga el estado actual +
                          del slot.') SEV(30)
             ENDDO

/*  SL11207 Slot inactive. */

             CHGVAR     VAR(&MSGID) VALUE('SL11207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot es inactivo.') +
                          SECLVL('Causa . . . . . :   El codigo del +
                          slot es inactivo, seleccione un slot activo. +
                          &N Recobro  . . . :   Seleccione un slot activo +
                          o cambie el estado del slot.') +
                          SEV(30)
             ENDDO

/*  SL11401 Slot can't be deleted because qty <> 0. */

             CHGVAR     VAR(&MSGID) VALUE('SL11401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot &1 no borrado.') SECLVL('Causa . . . +
                          . . :   El slot &1 no pudo ser borrado +
                          porque hay una cantidad ajuntado a si +
                          mismo. &N Recovery  . . . :   Use el +
                          programa de ajustamiento para reducir las +
                          cantidades a 0 e intente otra +
                          vez.') SEV(10) FMT((*CHAR 12))
             ENDDO

/*  SL13201 Invalid slot entered.  */

             CHGVAR     VAR(&MSGID) VALUE('SL13201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot de PIR no es valido.') SECLVL('Causa +
                          . . . . . :   El slot ''&1-&2-&3-&4'' no +
                          es valido. &N Recobro . . . :   La primera +
                          parte del campo de slot es el codigo del +
                          pasillo. Es alfanumerica y no puede ser +
                          blanca. La segunda parte es la ubicacion +
                          del slot en el pasillo. Es numerica y debe +
                          ser mas grande que 0. La tercera parte +
                          identifica el nivel del entrepano. Es +
                          numerica y debe ser mas grande que 0. La +
                          ultima parte es el indicador de handstack. +
                          Es alfanumerica y opcional.') SEV(30) +
                          FMT((*CHAR 3) (*DEC 3 0) (*DEC 3 0) +
                          (*CHAR 2))
             ENDDO

/*  SL13202 PIR slot already exists.  */

             CHGVAR     VAR(&MSGID) VALUE('SL13202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot ya existe como un slot de &5.') +
                          SECLVL('Causa . . . . . :   El slot +
                          ''&1-&2-&3&4'' ya existe como un slot de +
                          &5. &N Recovery  . . . :   Incorpore un +
                          numero de slot diferente para crear u +
                          oprima F12 para +
                          cancelar.') SEV(30) FMT((*CHAR 3) +
                          (*DEC 3 0) (*DEC 3 0) (*CHAR 2) (*CHAR 5))
             ENDDO

/*  SL13210 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL13210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Codigo de estado incorporado es +
                          invalido.') SECLVL('Causa . . . . . :   +
                          El codigo de estado incorporado no es +
                          ''A'' ''V'' o ''Z''. &N Recobro . . . : +
                          Incorpore ''A''(activo), ''V''(verificado) +
                          o ''Z'' (Puesto al 0).') SEV(30)
             ENDDO

/*  SL14201 Invalid slot entered.  */

             CHGVAR     VAR(&MSGID) VALUE('SL14201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El slot fijo no es valido.') +
                          SECLVL('Causa . . . . . :   El slot +
                          ''&1-&2-&3&4'' no es valido. &N Recobro  +
                          . . . :   La primera parte del campo de +
                          slot es el codigo de pasillo. Es +
                          alfanumerico y no puede ser blanco. La +
                          segunda parte es la ubicacion del slot en +
                          el pasillo. Es numerico y debe ser mas +
                          grande que 0. La tercera parte identifica +
                          el nivel del entrepano. Es numerico y debe +
                          ser mas grande que 0. La ultima parte es +
                          el inicador del handstack. Es alfanumerico +
                          y es opcional.') SEV(30) +
                          FMT((*CHAR 3) (*DEC 3 0) (*DEC 3 0) +
                          (*CHAR 2))
             ENDDO

/*  SL14202 PIR slot already exists.  */

             CHGVAR     VAR(&MSGID) VALUE('SL14202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot ya existe como un slot de &5.') +
                          SECLVL('Causa . . . . . :   El slot +
                          ''&1-&2-&3&4'' ya existe como un slot de +
                          &5. &N Recobro  . . . :   Incorpore un +
                          numero de slot diferente para crear u +
                          oprima F12 para +
                          cancelar.') SEV(30) FMT((*CHAR 3) +
                          (*DEC 3 0) (*DEC 3 0) (*CHAR 2) (*CHAR 5))
             ENDDO

/*  SL14210 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL14210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Codigo de estado incorporado es +
                          invalido.') SECLVL('Causa . . . . . :   +
                          El codigo de estado incorporado no es +
                          ''A'', ''V'' o ''Z''. &N Recobro . . . :   +
                          Incorpore ''A''(activo), ''V''(verificado) +
                          o ''Z''(Puesto al 0).') SEV(30)
             ENDDO

/*  SL14211 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL14211')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Codigo de estado incorporado no es +
                          valido.') SECLVL('Causa . . . . . :    +
                          Cuando un slot fijo es reservado por un +
                          producto, el unico estado valido es ''A''. +
                          &N Recobro . . . :   Incorpore ''A'' +
                          (activo) por el codigo de estado.') SEV(30)
             ENDDO

/*  SL15021 Invalid slot type entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL15021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Tipo de slot incorporado es +
                          invalido.') SECLVL('Causa . . . . . : El +
                          tipo de slot debe ser un ''F'' o ''P''. &N +
                          Recobro . . . :   Incorpore ''F'' por fijo +
                          o ''P'' por PIR.') SEV(30)
             ENDDO


/*  SL15201 Slots verified.                */

             CHGVAR     VAR(&MSGID) VALUE('SL15201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          de los slots verificados con exito.') +
                          SECLVL('Causa . . . . . :   &1 de los +
                          slots verificados con exito. &N Recobro . +
                          . . : El recobro no es +
                          requerido.') SEV(10) FMT((*DEC 5 0))
             ENDDO

/*  SL15421 Slot verified. */

             CHGVAR     VAR(&MSGID) VALUE('SL15421')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          verificado.') SECLVL('No hay mas +
                          informacion de este mensaje.') SEV(00) +
                          FMT((*CHAR 50))
             ENDDO

/*  SL15422 Slot can't be verified.   */

             CHGVAR     VAR(&MSGID) VALUE('SL15422')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El slot no puede ser verificado.') +
                          SECLVL('Causa . . . . . :   El slot tiene +
                          los slots virtuales asociado a si mismo +
                          &N Recobro  . . . : No requerido.') SEV(10)
             ENDDO

/*  SL16001 No more zero slots.            */

             CHGVAR     VAR(&MSGID) VALUE('SL16001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay mas slots de cero.') SECLVL('Causa . . +
                          . . . :   No hay mas slots de cero por el +
                          departamento o pasillo seleccionado.  &N +
                          Recobro . . . :   Oprima F12 para cancelar +
                          e incorporar un departamento nuevo, u +
                          oprima F3 para salir.') SEV(30)
             ENDDO


/*  SS11401 Slot status code cannot be deleted. */

             CHGVAR     VAR(&MSGID) VALUE('SS11401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          codigo de estado del slot no borrado.') +
                          SECLVL('Causa . . . . . :   El codigo de +
                          estado ''A'', ''I'', ''V'', o ''Z'' no +
                          puede ser borrado. &N Recobro . . . : +
                          Establezca contacto con el director de +
                          DP para recibir mas informacion.') +
                          SEV(10)
             ENDDO

/*  SL21201 Cannot enter item number for a verified slot status. */

             CHGVAR     VAR(&MSGID) VALUE('SL21201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede incorporar el numero de +
                          producto por un slot al estado de ''V'' +
                          (verificado).') SECLVL('Causa . . . . . : +
                          Esta tratando de incorporar un numero de +
                          producto que tiene un estado de ''V''. +
                          &N Recobro . . . :   Cambie el estado de +
                          ''V'' a otro mandato, o dejelo blanco. +
                          Entonces intente otra +
                          vez.') SEV(30)
             ENDDO

/*  SL22201 Slots cannot be deleted.                 */

             CHGVAR     VAR(&MSGID) VALUE('SL22201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar los slots +
                          seleccionados.') SECLVL('Causa . . . . . : +
                          El grupo de slots que esta tratando de +
                          borrar tiene &1 slots que continen +
                          productos. Los slots tienen que estar +
                          vacios para borrar. &N Recobro . . . :   +
                          Incorpore otro grupo de slots e intente +
                          otra vez.') SEV(30) +
                          FMT((*DEC 5 0))
             ENDDO

/*  SL22202 Slots deleted.                 */

             CHGVAR     VAR(&MSGID) VALUE('SL22202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots borrados con exito.') +
                          SECLVL('Causa . . . . . :   &1 slots +
                          fueron borrados con exito. &N Recobro . . +
                          . :  No requerido.') SEV(10) FMT((*DEC 5 0))
             ENDDO

/*  SL22203 Checking for active slots.     */

             CHGVAR     VAR(&MSGID) VALUE('SL22203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Buscando slots activos.  Tenga +
                          paciencia por favor.') SEV(10)
             ENDDO

/*  SL22204 Deletint slots.                */

             CHGVAR     VAR(&MSGID) VALUE('SL22204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Borrando los slots.  Tenga paciencia +
                          por favor.') SEV(10)
             ENDDO

/*  SL23201 Invalid status code entered.             */

             CHGVAR     VAR(&MSGID) VALUE('SL23201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Codigo de estado incorporado es +
                          invalido.') SECLVL('Causa . . . . . :   +
                          El codigo de estado incorporado es +
                          diferente que ''V'',''Z'',''I''. &N +
                          Recobro . . . :   Incorpore un codigo de +
                          estado valido e intente otra vez. Los +
                          codigos validos son V=verificado, Z=puesta +
                          al 0, I=inactivo.') SEV(30)
             ENDDO


/*  SL23202 Slots status cannot be changed.          */

             CHGVAR     VAR(&MSGID) VALUE('SL23202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          estado de slot no puede ser cambiado.') +
                          SECLVL('Causa . . . . . :   El grupo de +
                          slots que quiere cambiar el estado, tiene +
                          &1 slots activos. El estado de los slots +
                          no puede ser cambiado. &N Recobro . . . . : +
                          Incorpore otro grupo de slots e intente +
                          otra vez.') SEV(30) FMT((*DEC 5 0))
             ENDDO

/*  SL23203 Slot status changed.           */

             CHGVAR     VAR(&MSGID) VALUE('SL23203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El estado de &2 slots cambiado con +
                          exito, &1 slots no pudo cambiar.') +
                          SECLVL('Causa . . . . . :   El estado de +
                          &2 slots fue cambiado con exito, &1 slots +
                          no pudo cambiar. &N Recobro  . . . :   +
                          No requerido.') SEV(10) FMT((*DEC 5 0) +
                          (*DEC 5 0))
             ENDDO

/*  SL23204 Checking for active slots.     */

             CHGVAR     VAR(&MSGID) VALUE('SL23204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Buscando los slots activos. Tenga +
                          paciencia por favor.') SEV(10)
             ENDDO

/*  SL23205 Changing slot status.          */

             CHGVAR     VAR(&MSGID) VALUE('SL23205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cambiando el estado del slot. Tenga +
                          paciencia por favor.') SEV(10)
             ENDDO

/*  SL23206 Can't change from status code 'A'        */

             CHGVAR     VAR(&MSGID) VALUE('SL23206')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede cambiar el codigo de estado +
                          A.') SECLVL('Causa . . . . . :   El codigo +
                          de estado incorporado es diferente que +
                          ''V'', ''Z'', ''I''. &N Recobro . . . :   +
                          Incorpore un codigo de estado valido e +
                          intente otra vez. Los codigos validos son +
                          V=Verificado, Z=Puesta al 0, +
                          e I=Inactivo.') SEV(30)
             ENDDO

/*  LP11022 License not on file. */

             CHGVAR     VAR(&MSGID) VALUE('LP11022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Licencia no esta en el archivo.') +
                          SECLVL('Causa . . . . . :   La licencia no +
                          es encontrado en el archivo. &N Recobro . +
                          . . :   Este seguro que el almacen es +      +
                          correcto, incorpore una licencia +
                          correcta.') SEV(30)
             ENDDO

/*  SL24201 Slot designation code changed. */

             CHGVAR     VAR(&MSGID) VALUE('SL24201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El codigo de designacion de &2 slots +
                          fue cambiado con exito.') SECLVL('Causa . +
                          . . . . :   El codigo de designacion de &2 +
                          slots fue cambiado con exito. &N Recobro . +
                          . . :   No es +
                          requerido.') SEV(10) FMT((*DEC 5 +
                          0) (*DEC 5 0))
             ENDDO

/*  SL24202 Changing slot designation code.*/

             CHGVAR     VAR(&MSGID) VALUE('SL24202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cambiado el codigo de designacion de +
                          slot. Tenga paciencia por favor.') SEV(10)
             ENDDO

/*  SL25201 Not allowed to change item - Non-stock qtys exist. */

             CHGVAR     VAR(&MSGID) VALUE('SL25201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          puede cambiar el producto. El slot &1 +
                          contiene cantidades de no inventariar.') +
                          SECLVL('Causa . . . . . :   El slot &1 +
                          contiene una cantidad en el cubo de +
                          cantidad de Asignacion, Accion de escoger, +
                          Transferencia, o Recepcion. El producto de +
                          un numero de slot solamente puede ser +
                          cambiado si las cantidades son 0. &N +
                          Recobro . . . :   Cierre algunas +
                          transacciones abiertas para reducir las +
                          cantidades a 0 e intente otra vez.') +
                          SEV(10) FMT((*CHAR 12))
             ENDDO

/*  SL25202 Item change completed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('SL25202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 en el slot &2 fue cambiado al +
                          producto &3 con exito.') SECLVL('Causa . . +
                          . . . :   El producto &1 en el slot &2 fue +
                          cambiado al producto &3 con exito. El slot +
                          se quedo lo mismo. Las cantidades del +
                          almacen fueron ajustadas por cada producto. +
                          &N Recobro . . . :   No hay recobro. Este +
                          es un mensaje de informacion.') +
                          SEV(10) FMT((*CHAR 15) (*CHAR +
                          12) (*CHAR 15))
             ENDDO

/*  SL25203 Item change can not be made - Invalid status code' */

             CHGVAR     VAR(&MSGID) VALUE('SL25203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Un cambio de producto no es permitido +
                          -codigo de estado de slot es invalido.') +
                          SECLVL('Causa . . . . . :   El slot &1 +
                          tiene un estado de &2. Cuando cambiando un +
                          producto, el codigo de estado no puede ser +
                          ''Z'' o ''V''. &N Recobro . . . :   +
                          Seleccione otro slot o cambie el codigo de +
                          estado e intente otra vez.') SEV(40) +
                          FMT((*CHAR 12) (*CHAR 2))
             ENDDO

/*  SL25273 Item change could not be made - Slot was deleted. */

             CHGVAR     VAR(&MSGID) VALUE('SL25273')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          cambio de producto no pudo ser completado. +
                          El slot no existe.') SECLVL('Causa . . . . +
                          . :   El slot que esta tratando de cambiar +
                          el producto por fue borrado antes de que +
                          oprimiera ENTER para hacer el ajustamiento. +
                          &N Recobro . . . :   El slot debe ser +
                          recreado antes de que pueda cambiarlo. +
                          Oprima F12 para cancelar este cambio y +
                          determinar la razon de la  borradura del +
                          slot.') SEV(40)
             ENDDO

/*  SL25274 Item change can not be made - record is locked.' */

             CHGVAR     VAR(&MSGID) VALUE('SL25274')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          cambio de producto no pudo ser completado- +
                          otro usuario esta usando el slot.') +
                          SECLVL('Causa . . . . . :   Otro usuario +
                          ya esta usando el slot que esta tratando +
                          de cambiar el producto por y no puede ser +
                          compartido. &N Recobro . . . :   Si +
                          continua de recibir este mensaje, +
                          establezca contacto con el director de +
                          DP.') SEV(40)
             ENDDO

/*  SL26201 Slot priority code changed. */

             CHGVAR     VAR(&MSGID) VALUE('SL26201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El codigo de prioridad de &2 slots +
                          cambiado con exito.') SECLVL('Causa . . +
                          . . . :   El codigo de prioridad de &2 +
                          slots fue cambiado con exito. &N Recobro +
                          . . . :   El recobro no es +
                          :   requerido.') SEV(10) FMT((*DEC 5 +
                          0) (*DEC 5 0))
             ENDDO


             RETURN
             ENDPGM
